# MK Studio VPN — Desktop setup (Windows / macOS / Linux)

One Flutter codebase branded **MK Studio VPN** for PC/laptop.

| | Windows | macOS | Linux |
|---|---|---|---|
| Display name | MK Studio VPN | MK Studio VPN | MK Studio VPN |
| Executable | `MKStudioVPN.exe` | `MK Studio VPN.app` | `mkstudiovpn` |
| App / package id | MSIX `MKStudio.VPN` | `com.mkstudio.vpn` | `com.mkstudio.vpn` |
| Install dir | `Program Files\MK Studio VPN` | `/Applications` | `.deb` / AppImage |
| Deep link | `mkstudiovpn://` (+ `hiddify://` compat) | same | same |
| Mutex / WM class | `MKStudioVPNMutex` | — | `com.mkstudio.vpn` |

Apple-specific signing / TestFlight details: see **[IOS-MAC-SETUP.md](IOS-MAC-SETUP.md)**.

---

## Why Windows cannot be built on this Mac / Linux VPS

Flutter **Windows** targets require:

- Windows 10/11 x64
- Visual Studio 2022 with **Desktop development with C++**
- Flutter stable matching `pubspec.yaml` (`>=3.32.0`)
- Inno Setup (for `.exe` installer) and optionally MSIX tooling

The build Mac and VPS `172.255.209.244` are **not Windows**, so they cannot produce `MKStudioVPN.exe`. Source + packaging configs are ready; build on a Windows machine (or a Windows CI runner / VM).

---

## Windows — one-shot build (recommended)

**This Mac / Linux VPS cannot produce a Windows `.exe`.** Flutter Windows builds need a real Windows 10/11 PC (or GitHub `windows-latest` runner).

### Option A — Windows PC (တစ်ခါဖွင့် → install တင်လို့ရ)

1. Install [Flutter](https://docs.flutter.dev/get-started/install/windows) + Visual Studio 2022 (**Desktop development with C++**)
2. Optional but recommended for Setup.exe: [Inno Setup 6](https://jrsoftware.org/isinfo.php)
3. Copy folder `clients/hiddify-mk-studio/` onto the Windows PC
4. Open PowerShell in that folder and run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build-and-publish-windows.ps1
```

Output in `out\`:

| File | User experience |
|---|---|
| `MK-Studio-VPN-Windows-latest.exe` | **Installer** — double-click → install → Start Menu / Desktop (needs Inno Setup) |
| `MK-Studio-VPN-Windows-Setup-x64.exe` | Same installer |
| `MK-Studio-VPN-Windows-latest.zip` | Extract → run `Install-MKStudioVPN.bat` → installs to AppData + shortcuts + launches |

Publish URLs (after upload to VPS):

```text
https://myominnoo.org/downloads/MK-Studio-VPN-Windows-latest.exe
https://myominnoo.org/downloads/MK-Studio-VPN-Windows-latest.zip
```

Inno script: `windows/packaging/exe/mkstudio_vpn.iss`

### Option B — GitHub Actions

Workflow: `.github/workflows/build-mkstudio-windows.yml`  
Actions → **Build MK Studio Windows** → Run workflow → download artifact **MK-Studio-VPN-Windows**.

### Manual steps (if you prefer)

```powershell
flutter doctor -v
flutter pub get
# core libs: make windows-libs  OR see script above
flutter build windows --release --target=lib/main_prod.dart
powershell -ExecutionPolicy Bypass -File scripts\package_windows.ps1
```

Release folder: `build\windows\x64\runner\Release\` → `MKStudioVPN.exe`

Do **not** overwrite `MK-Studio-VPN-latest.apk` when publishing Windows builds.

---

## Linux — interim build (already published)

A Linux x64 portable bundle was built on the VPS and published:

- https://myominnoo.org/downloads/MK-Studio-VPN-Linux-latest.tar.gz  
- https://myominnoo.org/downloads/MK-Studio-VPN-Linux-x64.tar.gz  

Extract and run `./mkstudiovpn` (GTK / desktop Linux required).

To rebuild on VPS:

```bash
cd /opt/hiddify-mk-studio
# ensure hiddify-core/bin has linux amd64 libs (make linux-amd64-libs)
export PATH=/opt/flutter/bin:$PATH
flutter build linux --release --target=lib/main_prod.dart
# then tar the build/linux/x64/release/bundle folder
```

Full `.deb` / AppImage packaging (optional):

```bash
make linux-install-deps
make linux-prepare CHANNEL=prod
make linux-release CHANNEL=prod
```

---

## macOS

See **[IOS-MAC-SETUP.md](IOS-MAC-SETUP.md)** (`make macos-prepare`, DMG packaging, Team ID).

---

## Branding checklist (already applied in tree)

- [x] Window title / mutex / exe name → MK Studio VPN / `MKStudioVPN`
- [x] `Runner.rc` Company/Product metadata
- [x] Inno Setup + MSIX packaging yaml
- [x] App icon from MK Studio launcher asset
- [x] Linux `APPLICATION_ID=com.mkstudio.vpn`, binary `mkstudiovpn`
- [x] Deep link `mkstudiovpn` primary (Flutter + MSIX/deb mime)
- [x] Android APK package `com.mkstudio.vpn` untouched by these desktop edits

### Note on tunnel service name

Go source uses `MKStudioVPNTunnelService`. **Prebuilt** `hiddify-core` Windows DLLs/CLI from upstream still register `HiddifyTunnelService` until you rebuild cores with `make build-windows-libs`. The installer stops **both** service names on upgrade.

---

## Smoke test after install

1. App shows **MK Studio VPN** in title bar and About  
2. Icon is MK Studio (teal), not Hiddify  
3. Import profile via `mkstudiovpn://…` or paste subscription  
4. Connect works; uninstall does not remove Android APK downloads on the server  

Support: https://t.me/mkstudio3  
Site: https://myominnoo.org  
