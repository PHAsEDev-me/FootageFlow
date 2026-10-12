#pragma once
#include <windows.h>
#include <string>

HRESULT StartNativeFileDrag(HWND owner, const std::wstring& file_path);
