# MK Studio VPN — one-shot Windows build + optional publish
# Run on Windows 10/11 x64 in PowerShell (from hiddify-mk-studio folder):
#   powershell -ExecutionPolicy Bypass -File scripts\build-and-publish-windows.ps1
#
# Optional env:
#   $env:VPS_HOST = "172.255.209.244"
#   $env:VPS_PASS = "..."   # if using plink/pscp publish
#   $env:SKIP_PUBLISH = "1"

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

Write-Host "===== MK Studio VPN Windows build =====" -ForegroundColor Cyan
Write-Host "Root: $Root"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "Flutter not found. Install Flutter 3.32+ and add to PATH. See DESKTOP-SETUP.md"
}

flutter config --enable-windows-desktop | Out-Null
flutter --version

Write-Host "`n[1/5] flutter pub get" -ForegroundColor Yellow
flutter pub get

Write-Host "`n[2/5] Download Windows core libs" -ForegroundColor Yellow
$CoreVer = "4.1.0"
if (Test-Path "dependencies.properties") {
  $line = Get-Content dependencies.properties | Where-Object { $_ -match '^core\.version=' } | Select-Object -First 1
  if ($line) { $CoreVer = ($line -split '=', 2)[1].Trim() }
}
$BinDir = Join-Path $Root "hiddify-core\bin"
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
$Url = "https://github.com/hiddify/hiddify-next-core/releases/download/v$CoreVer/hiddify-lib-windows-amd64.tar.gz"
$Tar = Join-Path $env:TEMP "hiddify-lib-windows-amd64.tar.gz"
Write-Host "Fetching $Url"
Invoke-WebRequest -Uri $Url -OutFile $Tar -UseBasicParsing
tar -xzf $Tar -C $BinDir
Write-Host "Core libs in $BinDir"

Write-Host "`n[3/5] flutter build windows --release" -ForegroundColor Yellow
flutter build windows --release --target=lib/main_prod.dart

$Release = Join-Path $Root "build\windows\x64\runner\Release"
if (-not (Test-Path (Join-Path $Release "MKStudioVPN.exe")) -and -not (Test-Path (Join-Path $Release "*.exe"))) {
  throw "Release folder missing exe: $Release"
}

Write-Host "`n[4/5] Package installer + portable zip" -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "out" | Out-Null
New-Item -ItemType Directory -Force -Path "dist\tmp" | Out-Null
Remove-Item -Recurse -Force "dist\tmp\MKStudioVPN" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path "dist\tmp\MKStudioVPN" | Out-Null
Copy-Item -Path "$Release\*" -Destination "dist\tmp\MKStudioVPN" -Recurse -Force

# Simple install helper inside portable folder (no Inno required)
$InstallBat = @'
@echo off
setlocal
set APP=MK Studio VPN
set SRC=%~dp0
set DEST=%LOCALAPPDATA%\%APP%
echo Installing %APP% to %DEST% ...
mkdir "%DEST%" 2>nul
xcopy /E /I /Y "%SRC%*" "%DEST%\" >nul
powershell -NoProfile -Command "$s=(New-Object -ComObject WScript.Shell); $i=$s.CreateShortcut([Environment]::GetFolderPath('Desktop')+'\%APP%.lnk'); $i.TargetPath='%DEST%\MKStudioVPN.exe'; $i.WorkingDirectory='%DEST%'; $i.Save(); $i=$s.CreateShortcut([Environment]::GetFolderPath('StartMenu')+'\Programs\%APP%.lnk'); $i.TargetPath='%DEST%\MKStudioVPN.exe'; $i.WorkingDirectory='%DEST%'; $i.Save()"
echo Done. Desktop shortcut created.
start "" "%DEST%\MKStudioVPN.exe"
'@
Set-Content -Path "dist\tmp\MKStudioVPN\Install-MKStudioVPN.bat" -Value $InstallBat -Encoding ASCII

$PortableZip = Join-Path $Root "out\MK-Studio-VPN-Windows-Portable-x64.zip"
$LatestZip = Join-Path $Root "out\MK-Studio-VPN-Windows-latest.zip"
Compress-Archive -Force -Path "dist\tmp\MKStudioVPN\*" -DestinationPath $PortableZip
Copy-Item -Force $PortableZip $LatestZip

# True Setup.exe via Inno Setup 6 if installed
$Iscc = @(
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles}\Inno Setup 6\ISCC.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($Iscc) {
  Write-Host "Compiling Inno Setup installer with $Iscc"
  & $Iscc "windows\packaging\exe\mkstudio_vpn.iss"
  $Setup = Join-Path $Root "out\MK-Studio-VPN-Windows-Setup-x64.exe"
  if (Test-Path $Setup) {
    Copy-Item -Force $Setup (Join-Path $Root "out\MK-Studio-VPN-Windows-latest.exe")
  }
} else {
  Write-Host "Inno Setup not found — portable zip includes Install-MKStudioVPN.bat (double-click to install)."
  Write-Host "For Setup.exe: install https://jrsoftware.org/isinfo.php then re-run this script."
}

if (Test-Path "scripts\package_windows.ps1") {
  try { & powershell -ExecutionPolicy Bypass -File "scripts\package_windows.ps1" } catch { Write-Host "package_windows.ps1 skipped: $_" }
}

Write-Host "`nArtifacts:" -ForegroundColor Green
Get-ChildItem out | Format-Table Name, Length

Write-Host "`n[5/5] Publish (optional)" -ForegroundColor Yellow
if ($env:SKIP_PUBLISH -eq "1") {
  Write-Host "SKIP_PUBLISH=1 — upload out\*.zip to https://myominnoo.org/downloads/ manually"
  exit 0
}

$HostName = if ($env:VPS_HOST) { $env:VPS_HOST } else { "172.255.209.244" }
$Remote = "/var/www/mkvpn/public/downloads/"

if (Get-Command scp -ErrorAction SilentlyContinue) {
  Write-Host "Uploading via scp to root@${HostName}:$Remote"
  scp $PortableZip "root@${HostName}:${Remote}MK-Studio-VPN-Windows-Portable-x64.zip"
  scp $LatestZip "root@${HostName}:${Remote}MK-Studio-VPN-Windows-latest.zip"
  if (Test-Path "out\MK-Studio-VPN-Windows-latest.exe") {
    scp "out\MK-Studio-VPN-Windows-latest.exe" "root@${HostName}:${Remote}MK-Studio-VPN-Windows-latest.exe"
  }
  if (Test-Path "out\MK-Studio-VPN-Windows-Setup-x64.exe") {
    scp "out\MK-Studio-VPN-Windows-Setup-x64.exe" "root@${HostName}:${Remote}MK-Studio-VPN-Windows-Setup-x64.exe"
  }
  Write-Host "Published. Download:" -ForegroundColor Green
  Write-Host "  https://myominnoo.org/downloads/MK-Studio-VPN-Windows-latest.exe   (installer, if built)"
  Write-Host "  https://myominnoo.org/downloads/MK-Studio-VPN-Windows-latest.zip   (portable + Install bat)"
} else {
  Write-Host "scp not found. Copy files from out\ to the server downloads folder."
  Write-Host "  MK-Studio-VPN-Windows-latest.exe  (preferred for users)"
  Write-Host "  MK-Studio-VPN-Windows-latest.zip"
}

Write-Host "`n===== DONE =====" -ForegroundColor Cyan
