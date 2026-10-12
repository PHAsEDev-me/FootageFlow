#include "native_multi_file_drag.h"

#include <windows.h>
#include <shlobj.h>
#include <shobjidl.h>
#include <wrl/client.h>

using Microsoft::WRL::ComPtr;

class MultiFileDropSource final : public IDropSource {
 public:
  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID riid, void** ppv) override {
    if (!ppv) return E_POINTER;
    *ppv = nullptr;
    if (riid == IID_IUnknown || riid == IID_IDropSource) {
      *ppv = static_cast<IDropSource*>(this);
      AddRef();
      return S_OK;
    }
    return E_NOINTERFACE;
  }
  ULONG STDMETHODCALLTYPE AddRef() override { return InterlockedIncrement(&refs_); }
  ULONG STDMETHODCALLTYPE Release() override {
    const auto refs = InterlockedDecrement(&refs_);
    if (!refs) delete this;
    return refs;
  }
  HRESULT STDMETHODCALLTYPE QueryContinueDrag(BOOL escape, DWORD key_state) override {
    if (escape) return DRAGDROP_S_CANCEL;
    if ((key_state & MK_LBUTTON) == 0) return DRAGDROP_S_DROP;
    return S_OK;
  }
  HRESULT STDMETHODCALLTYPE GiveFeedback(DWORD) override { return DRAGDROP_S_USEDEFAULTCURSORS; }
 private:
  LONG refs_ = 1;
};

bool StartNativeMultiFileDrag(const std::vector<std::wstring>& paths) {
  if (paths.empty()) return false;

  std::vector<PIDLIST_ABSOLUTE> pidls;
  pidls.reserve(paths.size());
  for (const auto& path : paths) {
    PIDLIST_ABSOLUTE pidl = nullptr;
    SFGAOF attrs = 0;
    if (SUCCEEDED(SHParseDisplayName(path.c_str(), nullptr, &pidl, 0, &attrs)) && pidl) {
      pidls.push_back(pidl);
    }
  }
  if (pidls.empty()) return false;

  ComPtr<IShellItemArray> items;
  std::vector<PCIDLIST_ABSOLUTE> const_pidls;
  const_pidls.reserve(pidls.size());
  for (auto p : pidls) const_pidls.push_back(p);
  HRESULT hr = SHCreateShellItemArrayFromIDLists(
      static_cast<UINT>(const_pidls.size()), const_pidls.data(), &items);

  ComPtr<IDataObject> data;
  if (SUCCEEDED(hr) && items) {
    hr = items->BindToHandler(nullptr, BHID_DataObject, IID_PPV_ARGS(&data));
  }

  for (auto p : pidls) CoTaskMemFree(p);
  if (FAILED(hr) || !data) return false;

  auto* source = new MultiFileDropSource();
  DWORD effect = DROPEFFECT_NONE;
  hr = DoDragDrop(data.Get(), source, DROPEFFECT_COPY, &effect);
  source->Release();
  return hr == DRAGDROP_S_DROP;
}
