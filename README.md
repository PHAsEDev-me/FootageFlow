# FootageFlow 🎬

**FootageFlow** is an open-source Windows application built for video editors to quickly download, collect, organize, and manage footage.

Created by **PHAsE**.

## ✨ Features

- Download media from YouTube, TikTok, Instagram, Pinterest, and other yt-dlp supported websites
- Full video downloads
- Audio-only downloads
- Download specific clips using start/end timestamps
- Video + Audio and Audio-only clip modes
- Download quality selection
- Project-based footage organization
- Searchable footage library
- Batch selection and management
- Move and copy footage between projects
- Drag & drop files from Windows Explorer into projects
- Drag multiple files directly into Adobe After Effects
- Download queue with progress tracking
- Pause, resume, cancel, retry, and redownload
- Duplicate detection with Replace / Keep Both
- Video, Audio, and Image detection
- Source badges for downloaded footage
- Import and export footage collections
- Download history
- Proxy / system network support
- yt-dlp integration
- FFmpeg integration
- Native Windows integration

## 🖥️ Requirements

- Windows 10 or Windows 11
- yt-dlp
- FFmpeg (required for clipping and some media operations)

Flutter is also required if you want to build FootageFlow from source.

## 🚀 Build from Source

Clone FootageFlow:

    git clone https://github.com/PHAsEDev-me/FootageFlow.git
    cd FootageFlow

Install dependencies:

    flutter pub get

Run on Windows:

    flutter run -d windows

Build a release:

    flutter build windows --release

## 📥 yt-dlp

FootageFlow uses **yt-dlp** as its download engine.

Download the latest Windows x64 version of yt-dlp and select `yt-dlp.exe` from FootageFlow Settings.

Keeping yt-dlp updated is recommended because websites frequently change their download systems.

## 🎞️ FFmpeg

FFmpeg is used for clipping and media processing.

Download FFmpeg and select `ffmpeg.exe` from FootageFlow Settings.

The application can still run without FFmpeg, but features that require FFmpeg may not be available.

## 🌐 TikTok & Network Access

TikTok availability may depend on your network, ISP, region, and current yt-dlp compatibility.

On networks where TikTok is restricted or inaccessible, a system-level network solution such as Cloudflare WARP may be required.

Cloudflare WARP is **not included or distributed with FootageFlow**.

## ⚠️ Disclaimer

FootageFlow is provided as a media downloading and management tool.

Users are responsible for ensuring that their use of downloaded content complies with applicable laws, copyright rules, and the terms of service of the websites they use.

FootageFlow is not affiliated with YouTube, TikTok, Instagram, Pinterest, Adobe, yt-dlp, FFmpeg, or Cloudflare.

## ❤️ Credits

**Created by PHAsE**

Telegram: `@PHAsEcut`

### Special Thanks

**TOKITO — @The_Tokito**

For support and contribution to the project.

## 📄 License

FootageFlow is open-source software licensed under the **MIT License**.

Copyright (c) 2026 PHAsE