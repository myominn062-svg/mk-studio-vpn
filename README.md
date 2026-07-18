# MK Studio VPN

Multi-platform VPN / proxy client based on [Sing-box](https://github.com/SagerNet/sing-box).

Forked from [Hiddify App](https://github.com/hiddify/hiddify-app) and rebranded for **MK Studio**.

| | |
|---|---|
| **App name** | MK Studio VPN |
| **Android package** | `com.mkstudio.vpn` |
| **Apple / Linux id** | `com.mkstudio.vpn` |
| **Website** | https://myominnoo.org |
| **Support** | https://t.me/mkstudio3 |
| **Privacy** | https://myominnoo.org/privacy |

## Downloads

| Platform | Link |
|---|---|
| **Android APK** | https://myominnoo.org/downloads/MK-Studio-VPN-latest.apk |
| **Windows** | https://myominnoo.org/downloads/MK-Studio-VPN-Windows-latest.exe *(installer — when published)* |
| **Linux** | https://myominnoo.org/downloads/MK-Studio-VPN-Linux-latest.tar.gz |

GitHub: https://github.com/myominn062-svg/mk-studio-vpn

## Features

- Android, iOS, Windows, macOS, Linux
- Import subscription / VLESS / VMess / Trojan / etc.
- TUN / system proxy modes (platform-dependent)
- Local profiles, QR scan + gallery import
- No Hiddify branding — MK Studio theme & identity

## Docs in this repo

- [MK-STUDIO-FORK.md](MK-STUDIO-FORK.md) — branding & release notes
- [DESKTOP-SETUP.md](DESKTOP-SETUP.md) — Windows / Linux / macOS build
- [IOS-MAC-SETUP.md](IOS-MAC-SETUP.md) — Apple build & TestFlight

## Build (short)

```bash
# Android (on Linux CI / VPS)
flutter build apk --release --target lib/main_prod.dart

# Windows (on Windows PC or GitHub Actions windows-latest)
powershell -ExecutionPolicy Bypass -File scripts/build-and-publish-windows.ps1
```

## License

GPL v3 — see [LICENSE.md](LICENSE.md). Upstream Hiddify copyright and GPL terms still apply; do not strip license headers.

## Credits

Based on [Hiddify](https://github.com/hiddify/hiddify-app) / Sing-box. Rebranded and customized by MK Studio.
