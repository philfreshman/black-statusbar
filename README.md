# Black Menu Bar

A small macOS menu bar app that makes the menu bar black with white icons, whatever wallpaper you use.

## How it works

macOS does not let apps paint the menu bar itself. Instead, it picks the menu bar colour and the icon colour (dark or white) from the part of the wallpaper behind the menu bar.

So the app makes a copy of your wallpaper with a solid black band where the menu bar sits, and sets that copy as the wallpaper. The menu bar then looks black and macOS switches the icons to white.

- It watches for wallpaper, Space and display changes, and updates the copy.
- If your wallpaper is a **folder** of pictures, the app takes over the rotation (macOS can only rotate the folder itself, not our copies). Pick the interval under **Change Folder Picture**, or use **Next Picture**.
- Turning **Black Menu Bar** off puts your original wallpaper (or folder) back.

Copies are stored in `~/Library/Application Support/BlackMenuBar/Wallpapers`.

## Build and run

Needs macOS 14 or later and Xcode (or the Swift toolchain).

```bash
./scripts/build-app.sh
```

```bash
open "build/Black Menu Bar.app"
```

To keep it, copy `build/Black Menu Bar.app` to `/Applications` and turn on **Launch at Login** in its menu.

## Tests

```bash
swift test
```

## Limits

- Dynamic (light/dark changing) and animated wallpapers become a still picture.
- With **System Settings → Menu Bar → Show menu bar background** turned on, macOS draws its own tint over the black band. Turn it off for a pure black bar.
