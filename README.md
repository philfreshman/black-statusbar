# Nightbar

A macOS menu bar app that makes the menu bar black with white icons, on any wallpaper.

Website: [nightbar.app](https://nightbar.app)

## Install

```bash
curl -fsSL https://nightbar.app/install.sh | bash
```

Or [download Nightbar.zip](https://github.com/philfreshman/nightbar/releases/latest/download/Nightbar.zip) and move it to Applications. Nightbar is not notarized, so macOS asks for confirmation the first time you open it.

## How it works

Nightbar puts a black strip behind the menu bar, just above the wallpaper. On a dark wallpaper that is enough: macOS draws a black bar with white icons.

On a light wallpaper, macOS lays a grey tint over the strip and may draw black text, because it picks the menu bar colours from the wallpaper itself. So Nightbar also puts a see-through layer over the menu bar that turns the grey black and the text white. Clicks pass straight through it. Your wallpaper is never changed.

Each Space gets its own set of these windows, so the bar stays black while you swipe between Spaces. A Space gets its set the first time you visit it after Nightbar starts. Full-screen apps are left alone.

This layer uses private Core Animation parts, so a future macOS may break it; the strip keeps working either way. It also shifts the colours of coloured menu bar icons, and it is off while the menu bar hides automatically.

## Development

Needs macOS 14+ and Xcode 26+.

```bash
swift test
```

```bash
./scripts/build-app.sh && open build/Nightbar.app
```

Branches, the website and releases are covered in [CONTRIBUTING.md](CONTRIBUTING.md).
