<p align="center">
  <img src=".github/assets/icon.png" width="128" height="128" alt="Nightbar icon">
</p>

<h1 align="center">Nightbar</h1>

<p align="center">
  <strong>A black menu bar for macOS.</strong><br>
  White icons on solid black, on any wallpaper. The notch disappears, your wallpaper stays untouched.
</p>

<p align="center">
  <a href="https://nightbar.app">nightbar.app</a> ·
  <a href="#install">Install</a> ·
  <a href="#how-it-works">How it works</a> ·
  <a href="https://github.com/philfreshman/nightbar/releases">Releases</a>
</p>

<p align="center">
  <img src=".github/assets/demo.gif" width="830" alt="A Mac desktop with a violet wallpaper. The cursor opens the Nightbar menu and switches Nightbar on: the menu bar turns black with white icons and the notch disappears. Then it switches on rounded corners below the bar, and switches Nightbar off again.">
</p>

```bash
curl -fsSL https://nightbar.app/install.sh | bash
```

Free · open source · every display

## 01 · Why Nightbar

**Less glare up top.**

- **Readable at a glance.** White icons on solid black, whatever the wallpaper.
- **The notch blends in.** The cut-out disappears into one clean edge.
- **Your wallpaper stays yours.** Never edited or replaced. Turn Nightbar off and it is all back.

## 02 · How it works

**Three layers. One of them is ours.**

macOS builds the top of the screen from stacked layers. Nightbar slips one black layer in between, so macOS sees black behind the menu bar and draws it black with white icons.

```text
                ┌────────────────────────────────────────────┐
  L3  Menu bar  │  Finder  File  Edit  View   N  wifi  21:30 │  drawn by macOS
                └────────────────────────────────────────────┘
                ┌────────────────────────────────────────────┐
  L2  Nightbar  │█████████████████  black   █████████████████│  black strip, ours
                └────────────────────────────────────────────┘
                ┌────────────────────────────────────────────┐
  L1  Wallpaper │░░░▒▒▒▓▓▓▒▒░░░░▒▒▓▓▓▓▒▒▒░░░▒▒▒▓▓▒▒░░░░▒▒▓▓▓▓│  untouched
                └────────────────────────────────────────────┘
                                      │
                                      ▼
                ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
              = ┃  Finder  File  Edit  View   N  wifi  21:30 ┃  black bar, white icons
                ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

1. **L1 · Your wallpaper.** Stays exactly as it is. Nightbar never edits or replaces it.
2. **L2 · Nightbar's black strip.** A borderless window as tall as the menu bar, slipped in just above the wallpaper and below your windows.
3. **L3 · The menu bar.** macOS samples what is behind it, sees black, and draws a black bar with white icons.

### On a light wallpaper

macOS picks the menu bar colours from the wallpaper itself, not from the strip. On a light wallpaper it lays a grey tint over the strip and may draw black text. So Nightbar adds a fourth, see-through layer on top that remaps those colours:

```text
                ┌────────────────────────────────────────────┐
  L4  Contrast  │ grey → black          black text → white   │  see-through, clicks pass through
                └────────────────────────────────────────────┘
  L3  Menu bar  │░░Finder░░File░░Edit░░View░░░N░░wifi░░21:30░│  grey tint, black text
  L2  Nightbar  │█████████████████  black   █████████████████│
  L1  Wallpaper │                 (light)                    │
```

This layer uses private Core Animation parts, so a future macOS may break it; the strip keeps working either way. It also shifts the colours of coloured menu bar icons, and it is off while the menu bar hides automatically.

### Spaces and full screen

Each Space gets its own set of these windows, so the bar stays black while you swipe between Spaces. A Space gets its set the first time you visit it after Nightbar starts. Full-screen apps are left alone.

## 03 · Settings

**That is the whole menu.** On or off, launch at login, quit. Rounded corners under the bar, if you like them.

```text
  ✓ Nightbar
    Rounded Corners  ›   Off · Low · Mid · High
  ─────────────────
  ✓ Launch at Login
    Hide Icon
  ─────────────────
    Check for Updates…
    Quit            ⌘Q
```

Every display · All Spaces · No special permissions

## 04 · Install

**One line in Terminal.**

```bash
curl -fsSL https://nightbar.app/install.sh | bash
```

1. **Paste it.** Copy the command into Terminal and press Return. It fetches the latest release from GitHub.
2. **It opens by itself.** Nightbar lands in Applications and starts. curl sets no quarantine flag, so macOS opens it without a warning.
3. **Keep it.** Turn on **Launch at Login** in its menu.

Or [download Nightbar.zip](https://github.com/philfreshman/nightbar/releases/latest/download/Nightbar.zip) and move it to Applications. Nightbar is not notarized, so macOS asks for confirmation the first time you open it. You can [read the install script](install.sh) first.

Needs macOS 14 or later.

## Development

Needs macOS 14+ and Xcode 26+.

```bash
swift test
```

```bash
./scripts/build-app.sh && open build/Nightbar.app
```

Branches, the website and releases are covered in [CONTRIBUTING.md](CONTRIBUTING.md).
