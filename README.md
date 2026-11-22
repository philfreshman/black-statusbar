# Nightbar

A small macOS menu bar app that makes the menu bar black with white icons, whatever wallpaper you use, including live wallpapers.

## How it works

macOS does not let apps paint the menu bar itself. Instead, it picks the menu bar look and the icon colour (dark or white) from what is behind the menu bar.

So the app puts a black strip behind the menu bar of every screen. The strip sits just above the wallpaper and below desktop icons and windows. The menu bar then looks black and macOS switches the icons to white. Your wallpaper itself is never changed.

## Build and run

Needs macOS 14 or later and Xcode 26 or later. The build script uses Xcode's `actool` to compile the app icon.

```bash
./scripts/build-app.sh
```

```bash
open "build/Nightbar.app"
```

To keep it, copy `build/Nightbar.app` to `/Applications` and turn on **Launch at Login** in its menu.

## App icon

The icon source is `Resources/AppIcon.icon`, an Icon Composer document. Open it in Icon Composer (it ships with Xcode) to edit it. The build script compiles it, so there are no generated icon files in the repo.

## Tests

```bash
swift test
```
