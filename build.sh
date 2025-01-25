#!/bin/bash

OUTPUT_APK="$(readlink -f ../polyExport/GGJ2025.apk)"

godot --headless --export-debug "Android" "$OUTPUT_APK"
adb install $OUTPUT_APK

