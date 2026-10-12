#include "native_file_drag.h"

#include <objbase.h>
#include <ole2.h>
#include <shlobj.h>
#include <shobjidl.h>
#include <windows.h>

// Use the Windows Shell itself to build the IDataObject instead of emulating
// CF_HDROP by hand. This makes the drag payload much closer to a drag that
// originates in File Explorer (important for stricter drop targets such as
// Adobe After Effects).
static HRESULT CreateExplorerStyleDataObject(const std::wstring& file_path,
                                             IDataObject** data_object) {
  if (!data_object) return E_POINTER;
  *data_object = nullptr;

  // Ask Windows Shell for the same data object it exposes for the actual
  // filesystem item. IShellItem::BindToHandler(BHID_DataObject) avoids the
  // SDK-dependent SHCreateDataObject overload/signature mismatch and produces
  // an Explorer-compatible IDataObject on supported Windows versions.
  IShellItem* shell_item = nullptr;
  HRESULT hr = SHCreateItemFromParsingName(file_path.c_str(), nullptr,
                                           IID_PPV_ARGS(&shell_item));
  if (FAILED(hr) || !shell_item) return FAILED(hr) ? hr : E_FAIL;

  hr = shell_item->BindToHandler(nullptr, BHID_DataObject,
                                 IID_PPV_ARGS(data_object));
  shell_item->Release();
  return hr;
}

class ExplorerLikeDropSource final : public IDropSource {
 public:
  ExplorerLikeDropSource() : ref_count_(1) {}

  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, void** out) override {
    if (!out) return E_POINTER;
    if (iid == IID_IUnknown || iid == IID_IDropSource) {
      *out = static_cast<IDropSource*>(this);
      AddRef();
      return S_OK;
    }
    *out = nullptr;
    return E_NOINTERFACE;
  }

  ULONG STDMETHODCALLTYPE AddRef() override {
    return InterlockedIncrement(&ref_count_);
  }

  ULONG STDMETHODCALLTYPE Release() override {
    const ULONG count = InterlockedDecrement(&ref_count_);
    if (!count) delete this;
    return count;
  }

  HRESULT STDMETHODCALLTYPE QueryContinueDrag(BOOL escape_pressed,
                                               DWORD key_state) override {
    if (escape_pressed) return DRAGDROP_S_CANCEL;
    if ((key_state & MK_LBUTTON) == 0) return DRAGDROP_S_DROP;
    return S_OK;
  }

  HRESULT STDMETHODCALLTYPE GiveFeedback(DWORD) override {
    return DRAGDROP_S_USEDEFAULTCURSORS;
  }

 private:
  ~ExplorerLikeDropSource() = default;
  LONG ref_count_;
};

static void SetPreferredCopyEffect(IDataObject* data_object) {
  if (!data_object) return;

  const CLIPFORMAT preferred_effect =
      static_cast<CLIPFORMAT>(RegisterClipboardFormatW(CFSTR_PREFERREDDROPEFFECT));
  if (!preferred_effect) return;

  HGLOBAL memory = GlobalAlloc(GHND | GMEM_SHARE, sizeof(DWORD));
  if (!memory) return;

  auto* effect = static_cast<DWORD*>(GlobalLock(memory));
  if (!effect) {
    GlobalFree(memory);
    return;
  }
  *effect = DROPEFFECT_COPY;
  GlobalUnlock(memory);

  FORMATETC format = {preferred_effect, nullptr, DVASPECT_CONTENT, -1,
                      TYMED_HGLOBAL};
  STGMEDIUM medium = {};
  medium.tymed = TYMED_HGLOBAL;
  medium.hGlobal = memory;
  medium.pUnkForRelease = nullptr;

  // fRelease=TRUE transfers ownership on success. Some Shell data objects do
  // not accept SetData; in that case keep the original Shell payload and free
  // our temporary allocation.
  if (FAILED(data_object->SetData(&format, &medium, TRUE))) {
    GlobalFree(memory);
  }
}

HRESULT StartNativeFileDrag(HWND owner, const std::wstring& file_path) {
  const DWORD attributes = GetFileAttributesW(file_path.c_str());
  if (attributes == INVALID_FILE_ATTRIBUTES ||
      (attributes & FILE_ATTRIBUTE_DIRECTORY)) {
    return HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND);
  }

  if (GetCapture() != nullptr) ReleaseCapture();

  const HRESULT ole_result = OleInitialize(nullptr);
  const bool should_uninitialize = SUCCEEDED(ole_result);
  if (FAILED(ole_result) && ole_result != RPC_E_CHANGED_MODE) {
    return ole_result;
  }

  IDataObject* data_object = nullptr;
  HRESULT hr = CreateExplorerStyleDataObject(file_path, &data_object);
  if (FAILED(hr) || !data_object) {
    if (should_uninitialize) OleUninitialize();
    return FAILED(hr) ? hr : E_FAIL;
  }

  SetPreferredCopyEffect(data_object);

  auto* drop_source = new ExplorerLikeDropSource();
  DWORD performed_effect = DROPEFFECT_NONE;
  hr = DoDragDrop(data_object, drop_source,
                  DROPEFFECT_COPY | DROPEFFECT_LINK, &performed_effect);

  drop_source->Release();
  data_object->Release();
  if (should_uninitialize) OleUninitialize();
  return hr;
}
