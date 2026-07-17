#!/usr/bin/env python3
"""Fix FGS (dataSync), branding, rebuild+sign+publish."""
import os, re, shutil, subprocess
from pathlib import Path

ROOT = Path("/root/mk-hiddify-rebrand")
DECODED = ROOT / "decoded"
DEST = Path("/var/www/mkvpn/public/downloads")
BT = "/root/android-sdk/build-tools/34.0.0"
KS = "/root/mk-studio-vpn.keystore"
ASSETS = Path("/root/mk-studio-assets")

def run(cmd, env=None):
    print("+", " ".join(cmd), flush=True)
    subprocess.check_call(cmd, env=env)

man = DECODED / "AndroidManifest.xml"
m = man.read_text()
# dataSync is understood by apktool's older framework; empty FGS type was breaking startService.
m = m.replace('android:foregroundServiceType=""', 'android:foregroundServiceType="dataSync"')
m = m.replace('android:foregroundServiceType="specialUse"', 'android:foregroundServiceType="dataSync"')
perm = 'android.permission.FOREGROUND_SERVICE_DATA_SYNC'
if perm not in m:
    m = m.replace(
        'android.permission.FOREGROUND_SERVICE_SPECIAL_USE"/>',
        'android.permission.FOREGROUND_SERVICE_SPECIAL_USE"/>\n    <uses-permission android:name="' + perm + '"/>',
    )
m = m.replace('android:label="Hiddify"', 'android:label="MK Studio VPN"')
m = m.replace("app.hiddify.com", "com.mkstudio.vpn")
man.write_text(m)
print("dataSync count", m.count('foregroundServiceType="dataSync"'), flush=True)

smali_dir = DECODED / "smali"
for p in smali_dir.rglob("*.smali"):
    t = p.read_text(errors="ignore")
    orig = t
    t = t.replace('"hiddify service"', '"MK Studio VPN service"')
    t = t.replace('"Hiddify"', '"MK Studio VPN"')
    if t != orig:
        p.write_text(t)
        print("smali", p.relative_to(smali_dir), flush=True)

img = DECODED / "assets/flutter_assets/assets/images"
if (ASSETS / "logo.svg").exists():
    shutil.copy2(ASSETS / "logo.svg", img / "logo.svg")
    print("logo.svg", flush=True)
if (ASSETS / "ic_launcher_foreground.png").exists():
    (DECODED / "res/drawable").mkdir(parents=True, exist_ok=True)
    shutil.copy2(ASSETS / "ic_launcher_foreground.png", DECODED / "res/drawable/ic_launcher_foreground.png")
for dens in ("mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi"):
    src = ASSETS / f"mipmap-{dens}/ic_launcher.png"
    if src.exists():
        d = DECODED / f"res/mipmap-{dens}"
        d.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, d / "ic_launcher.png")
        r = ASSETS / f"mipmap-{dens}/ic_launcher_round.png"
        if r.exists():
            shutil.copy2(r, d / "ic_launcher_round.png")

yml = DECODED / "apktool.yml"
yt = yml.read_text()
if "renameManifestPackage:" in yt:
    yt = re.sub(r"renameManifestPackage:.*", "renameManifestPackage: com.mkstudio.vpn", yt)
else:
    yt += "\nrenameManifestPackage: com.mkstudio.vpn\n"
yml.write_text(yt)

draw = DECODED / "res/drawable"
if draw.exists():
    for name in list(os.listdir(draw)):
        if name.startswith("$avd_"):
            os.rename(draw / name, draw / name[1:])
            print("renamed", name, flush=True)
    pub = DECODED / "res/values/public.xml"
    if pub.exists():
        pub.write_text(pub.read_text().replace('name="$avd_', 'name="avd_'))
    for p in draw.glob("avd_*.xml"):
        p.write_text(p.read_text().replace("@drawable/$avd_", "@drawable/avd_"))

os.chdir(ROOT)
for f in ("unsigned2.apk", "aligned2.apk", "MK-Studio-VPN-v4.1.1-fixed.apk"):
    Path(f).unlink(missing_ok=True)

env = os.environ.copy()
env["PATH"] = BT + ":" + env.get("PATH", "")
run(["apktool", "b", "--use-aapt2", "-a", BT + "/aapt2", "decoded", "-o", "unsigned2.apk"], env=env)
run([BT + "/zipalign", "-f", "-p", "4", "unsigned2.apk", "aligned2.apk"])
run([
    BT + "/apksigner", "sign", "--ks", KS, "--ks-key-alias", "mkstudio",
    "--ks-pass", "pass:mkstudiovpn", "--key-pass", "pass:mkstudiovpn",
    "--v1-signing-enabled", "true", "--v2-signing-enabled", "true", "--v3-signing-enabled", "true",
    "--out", "MK-Studio-VPN-v4.1.1-fixed.apk", "aligned2.apk",
])
run([BT + "/apksigner", "verify", "--verbose", "MK-Studio-VPN-v4.1.1-fixed.apk"])
subprocess.check_call("aapt dump badging MK-Studio-VPN-v4.1.1-fixed.apk | head -8", shell=True)
subprocess.check_call(
    "aapt dump xmltree MK-Studio-VPN-v4.1.1-fixed.apk AndroidManifest.xml | grep -E 'VPNService|foregroundServiceType|dataSync|package=' | head -30",
    shell=True,
)

out = ROOT / "MK-Studio-VPN-v4.1.1-fixed.apk"
for dest in [
    DEST / "MK-Studio-VPN-v4.1.1.apk",
    DEST / "MK-Studio-VPN-latest.apk",
    DEST / "MK-Studio-VPN-HiddifyFork-v4.1.1.apk",
]:
    shutil.copy2(out, dest)
    os.chmod(dest, 0o644)
print("SIZE", out.stat().st_size, flush=True)
subprocess.check_call(["md5sum", str(DEST / "MK-Studio-VPN-latest.apk")])
print("PUBLISH_OK", flush=True)
