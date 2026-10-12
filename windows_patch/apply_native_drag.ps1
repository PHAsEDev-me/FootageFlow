$ErrorActionPreference = 'Stop'
$root = (Get-Location).Path
$runner = Join-Path $root 'windows\runner'
if (!(Test-Path $runner)) { throw 'Run this script from the Flutter project root.' }

Copy-Item (Join-Path $PSScriptRoot 'native_file_drag.h') (Join-Path $runner 'native_file_drag.h') -Force
Copy-Item (Join-Path $PSScriptRoot 'native_file_drag.cpp') (Join-Path $runner 'native_file_drag.cpp') -Force

$cmakePath = Join-Path $runner 'CMakeLists.txt'
$cmake = Get-Content $cmakePath -Raw

# Repair the malformed source entry produced by Step 7.13/7.13.1, e.g.
#   "flutter_window.cpp<newline>  native_file_drag.cpp"
# CMake interprets that as ONE filename. Always normalize it to two entries.
$brokenPattern = '(?s)["'']?flutter_window\.cpp\s*(?:`r?`n|\r?\n)\s*native_file_drag\.cpp["'']?'
$cmake = [regex]::Replace($cmake, $brokenPattern, '"flutter_window.cpp"' + "`r`n  " + '"native_file_drag.cpp"')

# Also normalize an unquoted/partially quoted native source entry if it already exists.
$cmake = [regex]::Replace($cmake, '(?m)^\s*["'']?native_file_drag\.cpp["'']?\s*$', '  "native_file_drag.cpp"')

if ($cmake -notmatch '(?m)^\s*"native_file_drag\.cpp"\s*$') {
  if ($cmake -match '(?m)^\s*"flutter_window\.cpp"\s*$') {
    $cmake = [regex]::Replace(
      $cmake,
      '(?m)^(\s*)"flutter_window\.cpp"\s*$',
      '$1"flutter_window.cpp"' + "`r`n" + '$1"native_file_drag.cpp"',
      1
    )
  } else {
    throw 'Could not find the flutter_window.cpp source entry in windows/runner/CMakeLists.txt'
  }
}
Set-Content $cmakePath $cmake -Encoding UTF8

$fwPath = Join-Path $runner 'flutter_window.cpp'
$fw = Get-Content $fwPath -Raw
if ($fw -notmatch 'footage_collector/native_file_drag') {
  $includeBlock = @'
#include "native_file_drag.h"
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
'@
  $fw = $fw -replace '#include "flutter_window.h"', "#include `"flutter_window.h`"`r`n$includeBlock"

  $anchor = 'SetChildContent(flutter_controller_->view()->GetNativeWindow());'
  if (-not $fw.Contains($anchor)) { throw 'Could not locate SetChildContent in flutter_window.cpp' }
  $channelCode = @'

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
'@
  $fw = $fw.Replace($anchor, $anchor + $channelCode)
  Set-Content $fwPath $fw -Encoding UTF8
}

Write-Host 'Explorer-style Shell drag installed (Adobe compatibility + SDK fix).' -ForegroundColor Green
Write-Host 'Now run: flutter clean; flutter pub get; flutter run -d windows'
