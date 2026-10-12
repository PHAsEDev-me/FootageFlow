$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$runner = Join-Path $root 'windows\runner'
$flutterWindow = Join-Path $runner 'flutter_window.cpp'
$cmake = Join-Path $runner 'CMakeLists.txt'
$mainCpp = Join-Path $runner 'main.cpp'

if (!(Test-Path $flutterWindow) -or !(Test-Path $cmake)) {
  throw 'Run this script from the Footage Collector project (windows/runner missing).'
}

Copy-Item (Join-Path $PSScriptRoot 'native_multi_file_drag.cpp') (Join-Path $runner 'native_multi_file_drag.cpp') -Force
Copy-Item (Join-Path $PSScriptRoot 'native_multi_file_drag.h') (Join-Path $runner 'native_multi_file_drag.h') -Force

# Add the native source to runner/CMakeLists.txt. This is idempotent.
$c = Get-Content $cmake -Raw
if ($c -notmatch 'native_multi_file_drag\.cpp') {
  $needle = '"flutter_window.cpp"'
  if (-not $c.Contains($needle)) {
    throw 'Could not find flutter_window.cpp in runner/CMakeLists.txt'
  }
  $replacement = '"flutter_window.cpp"' + [Environment]::NewLine + '  "native_multi_file_drag.cpp"'
  $c = $c.Replace($needle, $replacement)
  Set-Content -Path $cmake -Value $c -Encoding UTF8
}

# Register a MethodChannel in the existing Flutter window implementation.
$f = Get-Content $flutterWindow -Raw
if ($f -notmatch 'native_multi_file_drag\.h') {
  $includeNeedle = '#include "flutter_window.h"'
  if (-not $f.Contains($includeNeedle)) {
    throw 'Could not find flutter_window.h include in flutter_window.cpp'
  }
  $includeReplacement = '#include "flutter_window.h"' + [Environment]::NewLine + '#include "native_multi_file_drag.h"' + [Environment]::NewLine + '#include <flutter/method_channel.h>' + [Environment]::NewLine + '#include <flutter/standard_method_codec.h>'
  $f = $f.Replace($includeNeedle, $includeReplacement)
}

if ($f -notmatch 'footage_collector/native_multi_file_drag') {
  $anchor = 'RegisterPlugins(flutter_controller_->engine());'
  $engineExpr = 'flutter_controller_->engine()'
  if (-not $f.Contains($anchor)) {
    $anchor = 'RegisterPlugins(controller_->engine());'
    $engineExpr = 'controller_->engine()'
  }
  if (-not $f.Contains($anchor)) {
    throw 'Could not find RegisterPlugins(...) in flutter_window.cpp'
  }

  $inject = @"
$anchor

  // Footage Collector: Explorer/Adobe-compatible multi-file drag.
  static std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> multi_drag_channel;
  multi_drag_channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      $engineExpr->messenger(), "footage_collector/native_multi_file_drag",
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
"@
  $f = $f.Replace($anchor, $inject)
}

# Keep the native Windows title bar in sync with the public app name.
if (Test-Path $mainCpp) {
  $m = Get-Content $mainCpp -Raw
  $m = $m.Replace('L"footage_collector"', 'L"FootageFlow"')
  $m = $m.Replace('L"Footage Collector"', 'L"FootageFlow"')
  Set-Content -Path $mainCpp -Value $m -Encoding UTF8
}

Set-Content -Path $flutterWindow -Value $f -Encoding UTF8
Write-Host 'Multi-file Explorer/Adobe drag installed.' -ForegroundColor Green
Write-Host 'Now run: flutter clean; flutter pub get; flutter run -d windows'
