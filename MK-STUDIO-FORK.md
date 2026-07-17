# MK Studio VPN (Hiddify fork)

Rebranded fork of [Hiddify App](https://github.com/hiddify/hiddify-app) **v4.1.3**.

## Branding

- Display / launcher name: **MK Studio VPN**
- Android applicationId: `com.mkstudio.vpn`
- iOS / macOS bundle ID: `com.mkstudio.vpn` (VPN extension: `com.mkstudio.vpn.HiddifyPacketTunnel`)
- Windows executable: `MKStudioVPN.exe` (MSIX identity `MKStudio.VPN`)
- Linux binary / App ID: `mkstudiovpn` / `com.mkstudio.vpn`
- Deep link: `mkstudiovpn://` (primary), `hiddify://` (secondary)
- Icons / logo: MK Studio logo
- Support: https://t.me/mkstudio3
- Website: https://myominnoo.org
- Privacy: https://myominnoo.org/privacy
- Terms: https://myominnoo.org/terms

### Apple (iOS + macOS)

Source rebranded for both platforms as one Flutter effort. See **[IOS-MAC-SETUP.md](IOS-MAC-SETUP.md)** for build/run, Team ID placeholder, and TestFlight ($99 Apple Developer) steps. IPA is not produced until you sign on a Mac with full Xcode.

### Desktop (Windows + Linux)

Windows/Linux native packaging rebranded. See **[DESKTOP-SETUP.md](DESKTOP-SETUP.md)**. Windows `.exe` must be built on a Windows PC (Mac/VPS cannot cross-compile Flutter Windows).

## License (GPL)

Licensed under **GPL v3** with Hiddify additional terms — see `LICENSE.md`.  
Do not strip copyright headers. Redistribution must comply with GPL.

## Published APK

- Latest: https://myominnoo.org/downloads/MK-Studio-VPN-latest.apk (arm64, ~114MB)
- Versioned arm64: https://myominnoo.org/downloads/MK-Studio-VPN-v4.1.3-arm64.apk
- Universal: https://myominnoo.org/downloads/MK-Studio-VPN-v4.1.3-universal.apk
- Version: **4.1.5** (`versionCode` 40105)
- Package: `com.mkstudio.vpn`

## Published desktop (interim)

- Linux x64 portable: https://myominnoo.org/downloads/MK-Studio-VPN-Linux-latest.tar.gz
- Windows installer: **not yet** — needs a Windows PC build (see `DESKTOP-SETUP.md`); URL when ready: https://myominnoo.org/downloads/MK-Studio-VPN-Windows-latest.exe

### 2026-07-17 — Windows + Linux MK Studio rebrand

- Windows: `MKStudioVPN.exe`, installer/MSIX metadata, icon, mutex, deep link `mkstudiovpn`
- Linux: binary `mkstudiovpn`, `APPLICATION_ID=com.mkstudio.vpn`, deb/AppImage packaging
- Docs: `DESKTOP-SETUP.md` (Windows build requires a Windows machine)
- Android APK publishing path unchanged

### 2026-07-17 — iOS + macOS MK Studio rebrand

- Bundle IDs `com.mkstudio.vpn` / `com.mkstudio.vpn.HiddifyPacketTunnel`; display name MK Studio VPN
- `SERVICE_IDENTIFIER` aligned with Flutter/Android `MkStudioIdentifiers` channels
- Deep link `mkstudiovpn` primary; Hiddify signing/team removed (placeholder `DEVELOPMENT_TEAM`)
- Icons from MK Studio Android launcher asset; docs in `IOS-MAC-SETUP.md`

### 2026-07-17 v4.1.5 — Hiddify coexistence

- Isolated all runtime identifiers from Hiddify (`com.hiddify.app` → `com.mkstudio.vpn`):
  intent actions, Flutter method/event channels, notification channel, gRPC ports (27178/27179),
  VPN session name, stderr log filenames.
- VPN revoke / service-death no longer auto-reconnects or flickers error state when another VPN app connects.
- Version **4.1.5** (`versionCode` 40105).

### 2026-07-17 premium UI

- Full Flutter restyle: lime→teal MK Studio theme, Plus Jakarta Sans, hero home branding,
  pulsing Connect CTA, cleaned profiles/settings/about surfaces (no Hiddify purple look).
- Signed APK verified with `apksigner verify` (v2+v3).

## Install

1. Uninstall any previous MK Studio VPN / Hiddify-looking build (package `com.mkstudio.vpn`)
2. Open https://myominnoo.org/downloads/MK-Studio-VPN-latest.apk  
3. Allow install from browser / unknown sources if asked  
4. Open **MK Studio VPN** and import your subscription
