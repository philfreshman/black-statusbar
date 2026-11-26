# Nightbar

A macOS menu bar app that makes the menu bar black with white icons, on any wallpaper.

Website: [nightbar.app](https://nightbar.app)

## Install

```bash
curl -fsSL https://nightbar.app/install.sh | bash
```

Or [download Nightbar.zip](https://github.com/philfreshman/nightbar/releases/latest/download/Nightbar.zip) and move it to Applications. Nightbar is not notarized, so macOS asks for confirmation the first time you open it.

## How it works

macOS picks the menu bar colour from what is behind it. Nightbar puts a black strip behind the menu bar, just above the wallpaper, so macOS draws a black bar with white icons. Your wallpaper is never changed.

## Development

Needs macOS 14+ and Xcode 26+.

```bash
swift test
```

```bash
./scripts/build-app.sh && open build/Nightbar.app
```

Branches, the website and releases are covered in [CONTRIBUTING.md](CONTRIBUTING.md).
