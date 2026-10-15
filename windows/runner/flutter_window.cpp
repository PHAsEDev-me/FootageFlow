#include "flutter_window.h"
#include "native_multi_file_drag.h"
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include "native_file_drag.h"
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <optional>
#include <cstdio>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  // Persistent channel: its lifetime must match the Flutter engine.
  window_focus_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "footageflow/window_focus",
      &flutter::StandardMethodCodec::GetInstance());
  window_focus_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        std::fprintf(stderr, "[FootageFlow Native Focus] received method: %s\n", call.method_name().c_str());
        std::fflush(stderr);
        if (call.method_name() != "activate" && call.method_name() != "inspect") {
          result->NotImplemented();
          return;
        }
        HWND hwnd = GetHandle();
        if (!hwnd || !IsWindow(hwnd)) {
          result->Error("no_window", "FootageFlow HWND is unavailable");
          return;
        }
        const bool was_minimized = IsIconic(hwnd) != FALSE;
        if (call.method_name() == "activate") {
        if (was_minimized) ShowWindow(hwnd, SW_RESTORE);
        else ShowWindow(hwnd, SW_SHOW);
        SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0,
                     SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
        SetWindowPos(hwnd, HWND_NOTOPMOST, 0, 0, 0, 0,
                     SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
        BringWindowToTop(hwnd);

        HWND foreground = GetForegroundWindow();
        DWORD foreground_thread = foreground ? GetWindowThreadProcessId(foreground, nullptr) : 0;
        DWORD current_thread = GetCurrentThreadId();
        bool attached = false;
        if (foreground_thread && foreground_thread != current_thread) {
          attached = AttachThreadInput(current_thread, foreground_thread, TRUE) != FALSE;
        }
        const BOOL set_foreground_ok = SetForegroundWindow(hwnd);
        if (attached) AttachThreadInput(current_thread, foreground_thread, FALSE);
        const bool focused = GetForegroundWindow() == hwnd;
        if (!focused) {
          FLASHWINFO flash = {};
          flash.cbSize = sizeof(flash);
          flash.hwnd = hwnd;
          flash.dwFlags = FLASHW_TRAY | FLASHW_TIMERNOFG;
          flash.uCount = 3;
          FlashWindowEx(&flash);
        }
        std::fprintf(stderr, "[FootageFlow Native Focus] SetForegroundWindow=%d, attached=%d\n", set_foreground_ok != FALSE, attached);
        } // end activate; inspect must not change window state
        const bool currently_focused = GetForegroundWindow() == hwnd;
        const HWND above = GetWindow(hwnd, GW_HWNDPREV);
        const bool top_of_z_order = above == nullptr;
        const HWND foreground_now = GetForegroundWindow();
        DWORD foreground_pid = 0;
        if (foreground_now) GetWindowThreadProcessId(foreground_now, &foreground_pid);
        flutter::EncodableMap details;
        details[flutter::EncodableValue("focused")] = flutter::EncodableValue(currently_focused);
        details[flutter::EncodableValue("topOfZOrder")] = flutter::EncodableValue(top_of_z_order);
        details[flutter::EncodableValue("windowVisible")] = flutter::EncodableValue(IsWindowVisible(hwnd) != FALSE);
        details[flutter::EncodableValue("foregroundPid")] = flutter::EncodableValue(static_cast<int64_t>(foreground_pid));
        details[flutter::EncodableValue("foregroundHwnd")] = flutter::EncodableValue(static_cast<int64_t>(reinterpret_cast<intptr_t>(foreground_now)));
        details[flutter::EncodableValue("wasMinimized")] = flutter::EncodableValue(was_minimized);
        details[flutter::EncodableValue("hwnd")] = flutter::EncodableValue(static_cast<int64_t>(reinterpret_cast<intptr_t>(hwnd)));
        result->Success(flutter::EncodableValue(details));
      });

  std::fprintf(stderr, "[FootageFlow Native Focus] channel registered: footageflow/window_focus\n");
  std::fflush(stderr);

  // Footage Collector: Explorer/Adobe-compatible multi-file drag.
  static std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> multi_drag_channel;
  multi_drag_channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "footage_collector/native_multi_file_drag",
      &flutter::StandardMethodCodec::GetInstance());
  multi_drag_channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() != "startFilesDrag") {
          result->NotImplemented();
          return;
        }
        std::vector<std::wstring> paths;
        const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
        if (args) {
          auto it = args->find(flutter::EncodableValue("paths"));
          if (it != args->end()) {
            if (const auto* list = std::get_if<flutter::EncodableList>(&it->second)) {
              for (const auto& value : *list) {
                if (const auto* s = std::get_if<std::string>(&value)) {
                  if (!s->empty()) {
                    int n = MultiByteToWideChar(CP_UTF8, 0, s->c_str(), -1, nullptr, 0);
                    if (n > 1) {
                      std::wstring w(static_cast<size_t>(n), L'\0');
                      MultiByteToWideChar(CP_UTF8, 0, s->c_str(), -1, w.data(), n);
                      w.resize(static_cast<size_t>(n - 1));
                      paths.push_back(std::move(w));
                    }
                  }
                }
              }
            }
          }
        }
        result->Success(flutter::EncodableValue(StartNativeMultiFileDrag(paths)));
      });
  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  // Native Windows Shell drag source. CF_HDROP is the same file-drop format
  // accepted by Explorer and Adobe After Effects' Project panel.
  auto native_drag_channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(),
      "footage_collector/native_file_drag",
      &flutter::StandardMethodCodec::GetInstance());
  native_drag_channel->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() != "startFileDrag") {
          result->NotImplemented();
          return;
        }
        const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
        if (!args) { result->Error("bad_args", "Missing arguments"); return; }
        auto it = args->find(flutter::EncodableValue("path"));
        if (it == args->end()) { result->Error("bad_args", "Missing path"); return; }
        const auto* path_utf8 = std::get_if<std::string>(&it->second);
        if (!path_utf8) { result->Error("bad_args", "Invalid path"); return; }
        int len = MultiByteToWideChar(CP_UTF8, 0, path_utf8->c_str(), -1, nullptr, 0);
        std::wstring path(len > 0 ? len : 0, L'\0');
        if (len > 1) {
          MultiByteToWideChar(CP_UTF8, 0, path_utf8->c_str(), -1, path.data(), len);
          path.resize(len - 1);
        }
        HRESULT hr = StartNativeFileDrag(GetHandle(), path);
        if (hr == DRAGDROP_S_DROP || hr == DRAGDROP_S_CANCEL || SUCCEEDED(hr)) result->Success();
        else result->Error("drag_failed", "Windows OLE drag failed");
      });
  // Keep the MethodChannel alive for the lifetime of the Flutter window.
  // A local unique_ptr would be destroyed when OnCreate returns, making drag calls no-ops.
  native_drag_channel.release();

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  window_focus_channel_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
