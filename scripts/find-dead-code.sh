#!/usr/bin/env bash
# Finds unused declarations and imports with SwiftLint's analyzer rules (see .swiftlint.yml).
#
# `swiftlint analyze` reads each file's compiler arguments from a verbose build
# log. An incremental build logs only the files it recompiles, and SwiftLint
# skips files that are missing from the log, so this builds the app and the
# tests from scratch in a temporary folder every time.
set -euo pipefail

cd "$(dirname "$0")/.."

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

echo "Building the app and the tests from scratch..."
if ! swift build --build-tests -v --scratch-path "$scratch/build" > "$scratch/build.log" 2>&1; then
    cat "$scratch/build.log"
    exit 1
fi

swiftlint analyze --strict --quiet --compiler-log-path "$scratch/build.log"
echo "No dead code found."
