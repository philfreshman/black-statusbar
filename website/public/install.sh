#!/bin/bash
# Installs Nightbar, a black menu bar for macOS.
#
#   curl -fsSL https://nightbar.app/install.sh | bash
#
# Downloads the latest Nightbar.zip from GitHub releases, puts Nightbar.app in
# /Applications (or ~/Applications if /Applications is not writable), and opens it.
# Source: https://github.com/philfreshman/nightbar

set -euo pipefail

APP_NAME="Nightbar"
DOWNLOAD_URL="https://github.com/philfreshman/nightbar/releases/latest/download/Nightbar.zip"
tmp=""

say() { printf '\033[1m==>\033[0m %s\n' "$1"; }
fail() {
    printf '\033[31mError:\033[0m %s\n' "$1" >&2
    exit 1
}

# The whole script runs inside main, so nothing happens if the download is cut short.
main() {
    [ "$(uname -s)" = "Darwin" ] || fail "Nightbar runs on macOS only."

    local macos_major
    macos_major="$(sw_vers -productVersion | cut -d. -f1)"
    [ "$macos_major" -ge 14 ] || fail "Nightbar needs macOS 14 or later."

    local install_dir="/Applications"
    if [ ! -w "$install_dir" ]; then
        install_dir="$HOME/Applications"
        mkdir -p "$install_dir"
    fi
    local target="$install_dir/$APP_NAME.app"

    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT

    say "Downloading the latest $APP_NAME"
    curl -fsSL --proto '=https' --tlsv1.2 "$DOWNLOAD_URL" -o "$tmp/$APP_NAME.zip" ||
        fail "Could not download $DOWNLOAD_URL"

    ditto -x -k "$tmp/$APP_NAME.zip" "$tmp/unzipped"
    [ -d "$tmp/unzipped/$APP_NAME.app" ] || fail "The download did not contain $APP_NAME.app."

    if pgrep -xq "$APP_NAME"; then
        say "Quitting the running $APP_NAME"
        osascript -e "quit app \"$APP_NAME\"" >/dev/null 2>&1 || true
        for _ in 1 2 3 4 5 6 7 8 9 10; do
            pgrep -xq "$APP_NAME" || break
            sleep 0.5
        done
        pkill -x "$APP_NAME" 2>/dev/null || true
    fi

    if [ -e "$target" ]; then
        say "Replacing $target"
        rm -rf "$target" || fail "Could not remove the old $target"
    else
        say "Installing to $target"
    fi
    ditto "$tmp/unzipped/$APP_NAME.app" "$target"

    # curl sets no quarantine flag, so macOS opens the app without a Gatekeeper prompt.
    # Clear it anyway in case an older copy carried one.
    xattr -dr com.apple.quarantine "$target" 2>/dev/null || true

    local version
    version="$(defaults read "$target/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "")"

    open "$target"
    say "$APP_NAME${version:+ $version} is installed and running. Look for its icon in the menu bar."
}

main "$@"
