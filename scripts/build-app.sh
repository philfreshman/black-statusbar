#!/usr/bin/env bash
# Builds build/Nightbar.app from the Swift package.
set -euo pipefail

cd "$(dirname "$0")/.."

swift build -c release
binary_dir="$(swift build -c release --show-bin-path)"

app="build/Nightbar.app"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS"
cp "$binary_dir/Nightbar" "$app/Contents/MacOS/Nightbar"
cp Resources/Info.plist "$app/Contents/Info.plist"

# Compile the Icon Composer icon into Assets.car (macOS 26+) and AppIcon.icns (older macOS).
mkdir -p "$app/Contents/Resources"
xcrun actool Resources/AppIcon.icon \
    --compile "$app/Contents/Resources" \
    --platform macosx \
    --minimum-deployment-target 14.0 \
    --app-icon AppIcon \
    --output-partial-info-plist build/AppIcon-partial.plist \
    > /dev/null

# Ad-hoc signature: enough to run locally and to use "Launch at Login".
codesign --force --sign - "$app"

echo "Built $app"
