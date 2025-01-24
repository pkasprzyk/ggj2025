# Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
# powershell.exe -File .\build.ps1

Start-Process -Wait Godot_v4.3-stable_win64.exe '--headless --export-debug "Android" "..\polyExport\GGJ2025.apk"'
C:\Users\s-zep\AppData\Local\Android\Sdk\platform-tools\adb install "C:\MyGamez\polyExport\GGJ2025.apk"
