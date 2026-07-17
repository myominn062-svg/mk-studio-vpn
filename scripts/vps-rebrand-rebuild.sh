#!/bin/bash
set -euo pipefail
export PATH="/opt/flutter-338/bin:/root/flutter/bin:/root/android-sdk/cmdline-tools/latest/bin:/root/android-sdk/platform-tools:$PATH"
export ANDROID_HOME=/root/android-sdk
export ANDROID_SDK_ROOT=/root/android-sdk

ROOT=/root/mk-hiddify-rebrand
DECODED=$ROOT/decoded
DEST=/var/www/mkvpn/public/downloads
BT=/root/android-sdk/build-tools/34.0.0
KS=/root/mk-studio-vpn.keystore
SRC=/opt/hiddify-mk-studio
LOG=/root/mk-studio-rebuild.log

exec > >(tee -a "$LOG") 2>&1
echo "===== START $(date -Is) ====="

echo "=== PART A: apktool FGS + branding ==="

# Fix empty foregroundServiceType (root cause of startService failure)
python3 - <<'PY'
from pathlib import Path
import re
man = Path("/root/mk-hiddify-rebrand/decoded/AndroidManifest.xml")
m = man.read_text()
m = m.replace('android:foregroundServiceType=""', 'android:foregroundServiceType="specialUse"')
# ensure both services have specialUse
for svc in ("VPNService", "ProxyService"):
    pat = rf'(android:name="com\.hiddify\.hiddify\.bg\.{svc}"[^>]*?)android:foregroundServiceType="[^"]*"'
    m = re.sub(pat, rf'\1android:foregroundServiceType="specialUse"', m)
m = m.replace('android:label="Hiddify"', 'android:label="MK Studio VPN"')
m = m.replace("app.hiddify.com", "com.mkstudio.vpn")
man.write_text(m)
print("specialUse count", m.count('foregroundServiceType="specialUse"'))
for svc in ("VPNService", "ProxyService"):
    mm = re.search(rf'<service[^>]*{svc}[^>]*>', m)
    print(svc, (mm.group(0)[:240] if mm else "MISSING"))
PY

# Patch libapp.so URLs + visible Hiddify title (same-length)
python3 - <<'PY'
from pathlib import Path
p = Path("/root/mk-hiddify-rebrand/decoded/lib/arm64-v8a/libapp.so")
data = bytearray(p.read_bytes())

def u16(b: bytes) -> bytes:
    return b.decode("ascii").encode("utf-16le")

privacy = b"https://myominnoo.org/privacy?utm=mks"  # 36
assert len(privacy) == len(b"https://hiddify.com/privacy-policy/")
terms = b"https://myominnoo.org/terms"  # 26
assert len(terms) == len(b"https://hiddify.com/terms/")
mgr = b"https://myominnoo.org/?ref=mk"  # 28
assert len(mgr) == len(b"https://hiddify.com/manager/")
# 20 chars: t.me/mkstudio (user channel is mkstudio3; Flutter rebuild uses full URL)
tg = b"https://t.me/mkstudio"
assert len(tg) == len(b"https://t.me/hiddify")

repls = [
    (b"https://hiddify.com/terms/", terms),
    (b"https://hiddify.com/privacy-policy/", privacy),
    (b"https://hiddify.com/manager/", mgr),
    (b"https://t.me/hiddify", tg),
]
total = 0
for old, new in repls:
    c = data.count(old)
    if c:
        data = bytearray(bytes(data).replace(old, new))
        total += c
        print("utf8", old, "x", c)
    o16, n16 = u16(old), u16(new)
    c16 = data.count(o16)
    if c16:
        data = bytearray(bytes(data).replace(o16, n16))
        total += c16
        print("utf16", old, "x", c16)

# UTF-16 UI "Hiddify" -> "MK VPN " (7 chars) when not part of a longer word
old16 = "Hiddify".encode("utf-16le")
new16 = "MK VPN ".encode("utf-16le")
idx = 0
rep16 = 0
while True:
    i = data.find(old16, idx)
    if i < 0:
        break
    before = data[i - 2 : i] if i >= 2 else b""
    after = data[i + len(old16) : i + len(old16) + 2]

    def is_u16_letter(pair: bytes) -> bool:
        if len(pair) < 2 or pair[1] != 0:
            return False
        ch = pair[0]
        return (65 <= ch <= 90) or (97 <= ch <= 122)

    if is_u16_letter(before) or is_u16_letter(after):
        idx = i + 2
        continue
    data[i : i + len(old16)] = new16
    rep16 += 1
    idx = i + len(old16)
print("utf16 title reps", rep16)

needle = b"\x8eHiddify\x8d"
if needle in data:
    data = bytearray(bytes(data).replace(needle, b"\x8eMK VPN \x8d"))
    print("tagged appName replaced")
    total += 1

p.write_bytes(data)
print("libapp patch done", total)
for s in [b"https://t.me/hiddify", b"https://hiddify.com/terms/", b"https://hiddify.com/privacy-policy/", b"https://hiddify.com/manager/"]:
    print("remain", s, bytes(data).count(s))
PY

# Copy logos
ASSETS=/root/mk-studio-assets
IMG=$DECODED/assets/flutter_assets/assets/images
if [[ -f $ASSETS/logo.svg ]]; then
  cp -f $ASSETS/logo.svg "$IMG/logo.svg"
  echo "logo.svg updated"
fi
if [[ -f $ASSETS/ic_launcher_foreground.png ]]; then
  mkdir -p $DECODED/res/drawable
  cp -f $ASSETS/ic_launcher_foreground.png $DECODED/res/drawable/ic_launcher_foreground.png
fi
for dens in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  if [[ -f $ASSETS/mipmap-$dens/ic_launcher.png ]]; then
    mkdir -p $DECODED/res/mipmap-$dens
    cp -f $ASSETS/mipmap-$dens/ic_launcher.png $DECODED/res/mipmap-$dens/
    cp -f $ASSETS/mipmap-$dens/ic_launcher_round.png $DECODED/res/mipmap-$dens/ || true
  fi
done
[[ -f $ASSETS/mipmap-xhdpi/ic_banner.png ]] && cp -f $ASSETS/mipmap-xhdpi/ic_banner.png $DECODED/res/mipmap-xhdpi/ || true

# apktool.yml package
if grep -q 'renameManifestPackage:' $DECODED/apktool.yml; then
  sed -i 's/renameManifestPackage:.*/renameManifestPackage: com.mkstudio.vpn/' $DECODED/apktool.yml
else
  echo 'renameManifestPackage: com.mkstudio.vpn' >> $DECODED/apktool.yml
fi

# fix $avd_ drawable names
python3 - <<'PY'
import os
from pathlib import Path
DRAW = Path("/root/mk-hiddify-rebrand/decoded/res/drawable")
if DRAW.exists():
    for name in list(os.listdir(DRAW)):
        if name.startswith("$avd_"):
            os.rename(DRAW / name, DRAW / name[1:])
            print("renamed", name)
    pub = Path("/root/mk-hiddify-rebrand/decoded/res/values/public.xml")
    if pub.exists():
        pub.write_text(pub.read_text().replace('name="$avd_', 'name="avd_'))
    for p in DRAW.glob("avd_*.xml"):
        p.write_text(p.read_text().replace("@drawable/$avd_", "@drawable/avd_"))
PY

# Re-assert FGS after any edits
python3 - <<'PY'
from pathlib import Path
man = Path("/root/mk-hiddify-rebrand/decoded/AndroidManifest.xml")
m = man.read_text().replace('android:foregroundServiceType=""', 'android:foregroundServiceType="specialUse"')
man.write_text(m)
print("final specialUse", m.count('foregroundServiceType="specialUse"'))
PY

cd $ROOT
rm -f unsigned2.apk aligned2.apk MK-Studio-VPN-v4.1.1-fixed.apk
apktool b --use-aapt2 decoded -o unsigned2.apk
"$BT/zipalign" -f -p 4 unsigned2.apk aligned2.apk
"$BT/apksigner" sign --ks "$KS" --ks-key-alias mkstudio \
  --ks-pass pass:mkstudiovpn --key-pass pass:mkstudiovpn \
  --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true \
  --out MK-Studio-VPN-v4.1.1-fixed.apk aligned2.apk
"$BT/apksigner" verify --verbose MK-Studio-VPN-v4.1.1-fixed.apk
aapt dump badging MK-Studio-VPN-v4.1.1-fixed.apk | head -6
echo "=== FGS verify ==="
aapt dump xmltree MK-Studio-VPN-v4.1.1-fixed.apk AndroidManifest.xml | grep -E "VPNService|foregroundServiceType|specialUse" | head -20

cp -f MK-Studio-VPN-v4.1.1-fixed.apk "$DEST/MK-Studio-VPN-v4.1.1.apk"
cp -f MK-Studio-VPN-v4.1.1-fixed.apk "$DEST/MK-Studio-VPN-latest.apk"
cp -f MK-Studio-VPN-v4.1.1-fixed.apk "$DEST/MK-Studio-VPN-HiddifyFork-v4.1.1.apk"
chmod 644 "$DEST/MK-Studio-VPN-latest.apk" "$DEST/MK-Studio-VPN-v4.1.1.apk"
md5sum "$DEST/MK-Studio-VPN-latest.apk"
ls -la "$DEST/MK-Studio-VPN-latest.apk"
echo "PART_A_OK"

echo "=== PART B: Flutter rebuild (best effort) ==="
set +e
if [[ ! -x /opt/flutter-338/bin/flutter ]]; then
  echo "Installing Flutter 3.38.5..."
  cd /opt
  rm -rf flutter-338
  git clone --depth 1 --branch 3.38.5 https://github.com/flutter/flutter.git flutter-338
fi
export PATH="/opt/flutter-338/bin:$PATH"
flutter --version
if [[ -d $SRC/lib ]]; then
  cd $SRC
  cat > android/key.properties <<EOF
storePassword=mkstudiovpn
keyPassword=mkstudiovpn
keyAlias=mkstudio
storeFile=/root/mk-studio-vpn.keystore
EOF
  mkdir -p android/app/libs
  if ! ls android/app/libs/*.aar >/dev/null 2>&1; then
    CORE_VER=$(grep core.version dependencies.properties | cut -d= -f2)
    curl -fsSL "https://github.com/hiddify/hiddify-next-core/releases/download/v${CORE_VER}/hiddify-lib-android.tar.gz" | tar xz -C android/app/libs/ \
      || curl -fsSL "https://github.com/hiddify/hiddify-next-core/releases/download/v4.1.0/hiddify-lib-android.tar.gz" | tar xz -C android/app/libs/
  fi
  flutter pub get && dart run slang && dart run build_runner build --delete-conflicting-outputs
  flutter build apk --release --target lib/main_prod.dart
  APK=$(find build/app/outputs/flutter-apk -name '*release*.apk' | head -1)
  if [[ -n "$APK" ]]; then
    "$BT/apksigner" verify --verbose "$APK"
    cp -f "$APK" "$DEST/MK-Studio-VPN-v4.1.1-flutter.apk"
    cp -f "$APK" "$DEST/MK-Studio-VPN-latest.apk"
    cp -f "$APK" "$DEST/MK-Studio-VPN-v4.1.1.apk"
    chmod 644 "$DEST/MK-Studio-VPN-latest.apk"
    md5sum "$DEST/MK-Studio-VPN-latest.apk"
    echo "PART_B_OK"
  else
    echo "PART_B_FAIL no apk"
  fi
else
  echo "PART_B_SKIP no source at $SRC"
fi
set -e
echo "===== DONE $(date -Is) ====="
