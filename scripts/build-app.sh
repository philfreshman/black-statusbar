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

# Ad-hoc signature: enough to run locally and to use "Launch at Login".
codesign --force --sign - "$app"

echo "Built $app"
