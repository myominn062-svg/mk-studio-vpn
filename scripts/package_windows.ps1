New-Item -ItemType Directory -Force -Name "dist\tmp"
New-Item -ItemType Directory -Force -Name "out"

# Windows installer / MSIX → published download names
Get-ChildItem -Recurse -File -Path "dist" -Filter "*windows-setup.exe" | Copy-Item -Destination "out\MK-Studio-VPN-Windows-Setup-x64.exe" -ErrorAction SilentlyContinue
Get-ChildItem -Recurse -File -Path "dist" -Filter "*windows.msix" | Copy-Item -Destination "out\MK-Studio-VPN-Windows-Setup-x64.msix" -ErrorAction SilentlyContinue

# Also publish a stable "latest" installer name for https://myominnoo.org/downloads/
Get-ChildItem -Recurse -File -Path "dist" -Filter "*windows-setup.exe" | Copy-Item -Destination "out\MK-Studio-VPN-Windows-latest.exe" -ErrorAction SilentlyContinue

# Windows portable zip from Release runner output
xcopy "build\windows\x64\runner\Release" "dist\tmp\MKStudioVPN" /E/H/C/I/Y
xcopy ".github\help\mac-windows\*.url" "dist\tmp\MKStudioVPN" /E/H/C/I/Y
Compress-Archive -Force -Path "dist\tmp\MKStudioVPN" -DestinationPath "out\MK-Studio-VPN-Windows-Portable-x64.zip" -ErrorAction SilentlyContinue

Remove-Item -Path "$HOME\.pub-cache\git\cache\flutter_circle_flags*" -Force -Recurse -ErrorAction SilentlyContinue

echo "Done"
