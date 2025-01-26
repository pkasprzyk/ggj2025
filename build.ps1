# Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
# powershell.exe -File .\build.ps1

Start-Process -Wait Godot_v4.3-stable_win64.exe '--headless --export-debug "Android" "..\polyExport\GGJ2025.apk"'
C:\Users\s-zep\AppData\Local\Android\Sdk\platform-tools\adb install "C:\MyGamez\polyExport\GGJ2025.apk"
butler.exe push ..\polyExport\GGJ2025.apk namespacev/ggj2025:android

Start-Process -Wait Godot_v4.3-stable_win64.exe '--headless --export-debug "Web" "..\polyExport\web\index.html"'
7z a  ..\polyExport\web.zip ..\polyExport\web\*
butler.exe push ..\polyExport\web.zip namespacev/ggj2025:web

Start-Process -Wait Godot_v4.3-stable_win64.exe '--headless --export-debug "Windows" "..\polyExport\win\GGJ2025.exe"'
7z a  ..\polyExport\windows.zip ..\polyExport\win\*
butler.exe push ..\polyExport\windows.zip namespacev/ggj2025:windows

Start-Process -Wait Godot_v4.3-stable_win64.exe '--headless --export-debug "Linux" "..\polyExport\linux\GGJ2025-linux.x86_64"'
7z a  ..\polyExport\linux.zip ..\polyExport\linux\*
butler.exe push ..\polyExport\linux.zip namespacev/ggj2025:linux
