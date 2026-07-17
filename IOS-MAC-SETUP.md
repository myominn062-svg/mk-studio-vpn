# MK Studio VPN — iOS & macOS setup

One shared Flutter codebase, branded **MK Studio VPN** for both Apple platforms.

For Windows / Linux desktop packaging and Windows PC build steps, see **[DESKTOP-SETUP.md](DESKTOP-SETUP.md)**.

| Item | Value |
|------|--------|
| Display name | MK Studio VPN |
| Bundle ID | `com.mkstudio.vpn` |
| VPN extension | `com.mkstudio.vpn.HiddifyPacketTunnel` |
| App group | `group.com.mkstudio.vpn` |
| Method channels | `com.mkstudio.vpn/method`, `…/platform`, `…/service.status`, `…/service.alerts` (same as Android `MkStudioIdentifiers`) |
| Deep link (primary) | `mkstudiovpn://` |
| Deep link (compat) | `hiddify://` and common proxy schemes |
| Version | aligned with `pubspec.yaml` (currently **4.1.7+40107**) |

> **This Mac (dev machine note):** full **Xcode.app** is required to compile. Command Line Tools alone are not enough. This environment is **macOS 12.7** with no Xcode.app; current Flutter also expects **macOS 14+**. Use a newer Mac (or CI) when building IPA/DMG.

---

## What is ready (no Apple Developer purchase needed yet)

- Source rebrand for **iOS + macOS** (names, IDs, icons, deep links, channels)
- `DEVELOPMENT_TEAM` left **blank** — fill your Team ID later
- No Hiddify signing secrets / provisioning profiles shipped
- Android branding/channels unchanged and still isolated as `com.mkstudio.vpn`

**Not ready on this machine:** signed IPA / TestFlight / App Store upload (needs Xcode + paid Apple Developer Program).

---

## Prerequisites (when you build for real)

1. **Mac** with a supported macOS for current Xcode
2. **Xcode** from the Mac App Store (not only Command Line Tools)
3. `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
4. **Flutter** (see `pubspec.yaml` `flutter:` constraint, e.g. ≥ 3.32)
5. CocoaPods: `sudo gem install cocoapods` (or Homebrew)
6. Optional later: **Apple Developer Program ($99/year)** for device VPN entitlement, TestFlight, App Store

---

## One-time Apple Developer steps (later, for device / TestFlight)

1. Enroll at https://developer.apple.com/programs/ ($99/yr)
2. In Xcode → Settings → Accounts, add your Apple ID; note **Team ID**
3. Set Team ID in:
   - `ios/Base.xcconfig` → `DEVELOPMENT_TEAM=YOUR_TEAM_ID`
   - `macos/Runner/Configs/AppInfo.xcconfig` → `DEVELOPMENT_TEAM = YOUR_TEAM_ID`
   - `ios/exportOptions.plist` → `teamID` (and create matching provisioning profiles if not using Automatic)
4. In [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list):
   - App ID `com.mkstudio.vpn` with **Network Extensions** + **App Groups**
   - App ID `com.mkstudio.vpn.HiddifyPacketTunnel` (Packet Tunnel)
   - App Group `group.com.mkstudio.vpn`
5. Open `ios/Runner.xcworkspace`, select **Runner** + extension targets → Signing & Capabilities → your team (Automatic signing is fine to start)

VPN Network Extension capabilities **require** the paid program for real devices. Simulator has limited VPN support.

---

## Prepare native cores / deps

From `clients/hiddify-mk-studio/`:

```bash
# iOS core xcframework + Flutter deps
make ios-prepare

# macOS dylib + Flutter deps
make macos-prepare

# or manually:
flutter pub get
cd ios && pod install && cd ..
cd macos && pod install && cd ..
```

If `make ios-libs` / `macos-libs` downloads fail, build cores from `hiddify-core` per upstream Makefile (`build-ios-libs` / `build-macos-libs`).

---

## Run (debug)

```bash
# iOS Simulator (UI only; VPN tunnel limited)
flutter run -d ios

# Physical iPhone (needs Team ID + provisioning)
flutter run -d <device-id>

# macOS desktop
flutter run -d macos
```

Open in Xcode when debugging signing/entitlements:

- iOS: `ios/Runner.xcworkspace`
- macOS: `macos/Runner.xcworkspace`

---

## Release builds

```bash
# iOS IPA (needs signing configured)
make ios-release
# or:
flutter build ipa --export-options-plist=ios/exportOptions.plist

# macOS DMG / PKG
make macos-release
# or:
flutter build macos --release
```

Upload IPA via Xcode Organizer or `xcrun altool` / Transporter → TestFlight.

**IPA download for users:** only after you sign & distribute (TestFlight or App Store). This repo does not produce a usable IPA without your Apple account.

---

## Deep links

Examples:

- `mkstudiovpn://import/https%3A%2F%2Fexample.com%2Fsub`
- `mkstudiovpn://?url=https://example.com/sub&name=MyProfile`

`hiddify://` still works as a secondary scheme so old links do not break.

---

## Channel alignment (Flutter ↔ native)

| Flutter (`MkStudioIdentifiers`) | iOS (`SERVICE_IDENTIFIER` in `Base.xcconfig`) | Android |
|---------------------------------|-----------------------------------------------|---------|
| `com.mkstudio.vpn/method` | `com.mkstudio.vpn/method` | same |
| `com.mkstudio.vpn/platform` | `com.mkstudio.vpn/platform` | same |
| `com.mkstudio.vpn/service.status` | same | same |
| `com.mkstudio.vpn/service.alerts` | same | same |

iOS handlers read `Bundle.main.serviceIdentifier` from Info.plist → `SERVICE_IDENTIFIER`.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `xcodebuild` requires Xcode | Install Xcode.app; `xcode-select -s /Applications/Xcode.app/Contents/Developer` |
| Signing / provisioning errors | Set `DEVELOPMENT_TEAM`; enable Automatic signing; create App IDs + App Group |
| VPN won’t start on device | Paid team + Network Extension capability on both app + `HiddifyPacketTunnel` |
| Pods out of date | `cd ios && pod install --repo-update` |
| Channel mismatch / method not implemented | Confirm `SERVICE_IDENTIFIER=com.mkstudio.vpn` and clean rebuild |
| Old Hiddify app still installed | Different bundle ID — both can coexist; uninstall if testing side-by-side confusion |

---

## Related docs

- Android / fork notes: `MK-STUDIO-FORK.md`
- Upstream project: `README.md`
