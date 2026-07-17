#!/bin/bash
# Full Flutter release build + publish for MK Studio VPN (premium UI).
set -euo pipefail
export PATH="/opt/flutter-338/bin:/root/flutter/bin:/root/android-sdk/cmdline-tools/latest/bin:/root/android-sdk/platform-tools:$PATH"
export ANDROID_HOME=/root/android-sdk
export ANDROID_SDK_ROOT=/root/android-sdk
export PUB_CACHE=/root/.pub-cache

SRC=/root/hiddify-mk-studio
DEST=/var/www/mkvpn/public/downloads
BT=/root/android-sdk/build-tools/34.0.0
KS=/root/mk-studio-vpn.keystore
LOG=/root/mk-studio-flutter-ui.log
VER=4.1.7

exec > >(tee -a "$LOG") 2>&1
echo "===== FLUTTER UI BUILD START $(date -Is) ====="

cd "$SRC"

# Prefer Flutter 3.38 if present, else system flutter
if [[ -x /opt/flutter-338/bin/flutter ]]; then
  export PATH="/opt/flutter-338/bin:$PATH"
fi

flutter --version || true

cat > android/key.properties <<EOF
storePassword=mkstudiovpn
keyPassword=mkstudiovpn
keyAlias=mkstudio
storeFile=/root/mk-studio-vpn.keystore
EOF

mkdir -p android/app/libs
if ! ls android/app/libs/*.aar >/dev/null 2>&1; then
  echo "Fetching hiddify android libs..."
  CORE_VER=$(grep core.version dependencies.properties | cut -d= -f2 || echo "4.1.0")
  curl -fsSL "https://github.com/hiddify/hiddify-next-core/releases/download/v${CORE_VER}/hiddify-lib-android.tar.gz" | tar xz -C android/app/libs/ \
    || curl -fsSL "https://github.com/hiddify/hiddify-next-core/releases/download/v4.1.0/hiddify-lib-android.tar.gz" | tar xz -C android/app/libs/
fi

# Ensure geom binaries / native deps if Makefile expects them
if [[ -f Makefile ]]; then
  make get || true
fi

flutter pub get
dart run slang || true
dart run build_runner build --delete-conflicting-outputs || dart run build_runner build --delete-conflicting-outputs

# Release APK
flutter build apk --release --target lib/main_prod.dart --split-per-abi || \
  flutter build apk --release --target lib/main_prod.dart

APK=$(find build/app/outputs/flutter-apk -name 'app-*-release.apk' | grep -E 'arm64|release' | head -1)
if [[ -z "$APK" ]]; then
  APK=$(find build/app/outputs/flutter-apk -name '*release*.apk' | head -1)
fi
echo "Built APK: $APK"
test -n "$APK" -a -f "$APK"

# Prefer arm64 universal or fat apk for latest
FAT=$(find build/app/outputs/flutter-apk -name 'app-release.apk' | head -1)
if [[ -n "$FAT" && -f "$FAT" ]]; then
  APK="$FAT"
fi

# Re-sign to guarantee our keystore (Flutter may already sign via key.properties)
ALIGNED=/tmp/mk-studio-aligned.apk
SIGNED="/tmp/MK-Studio-VPN-v${VER}.apk"
"$BT/zipalign" -f -p 4 "$APK" "$ALIGNED"
"$BT/apksigner" sign --ks "$KS" --ks-key-alias mkstudio \
  --ks-pass pass:mkstudiovpn --key-pass pass:mkstudiovpn \
  --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true \
  --out "$SIGNED" "$ALIGNED"
"$BT/apksigner" verify --verbose "$SIGNED"
aapt dump badging "$SIGNED" | sed -n '1,8p' || true

mkdir -p "$DEST"
cp -f "$SIGNED" "$DEST/MK-Studio-VPN-v${VER}.apk"
cp -f "$SIGNED" "$DEST/MK-Studio-VPN-latest.apk"
chmod 644 "$DEST/MK-Studio-VPN-latest.apk" "$DEST/MK-Studio-VPN-v${VER}.apk"
md5sum "$DEST/MK-Studio-VPN-latest.apk"
ls -la "$DEST/MK-Studio-VPN-latest.apk"
echo "FLUTTER_UI_BUILD_OK"
echo "===== DONE $(date -Is) ====="
