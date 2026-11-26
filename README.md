# Nightbar

A small macOS menu bar app that makes the menu bar black with white icons, whatever wallpaper you use, including live wallpapers.

**[Download Nightbar](https://github.com/philfreshman/nightbar/releases/latest/download/Nightbar.zip)** · [nightbar.app](https://nightbar.app)

## Install

Paste this into Terminal. It downloads the latest release, puts Nightbar in `/Applications` and opens it:

```bash
curl -fsSL https://nightbar.app/install.sh | bash
```

Run it again to update. The script is [`website/public/install.sh`](website/public/install.sh). Or download `Nightbar.zip` above and move Nightbar into Applications yourself; macOS then asks for confirmation the first time you open it.

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

## Releases

Releases are built by GitHub Actions (`.github/workflows/release.yml`). After `development` has been merged into `main`, tag the merge commit on `main` and push the tag:

```bash
git checkout main && git pull
git tag v1.0.0
git push origin v1.0.0
```

The workflow tests and builds the app on macOS, sets the version from the tag, and publishes `Nightbar.zip` on a GitHub release. The website's download button always serves the latest release's `Nightbar.zip`, and `https://nightbar.app/download` redirects to it.

The app is signed ad hoc, not notarized, so macOS asks for confirmation the first time it is opened.

## Website

The landing page at [nightbar.app](https://nightbar.app) lives in `website/`. It is a minimal [Vite+](https://viteplus.dev) project using [Bun](https://bun.sh) with plain HTML, CSS and JavaScript, deployed by Vercel with `website` as the project's root directory. To preview it locally:

```bash
cd website && bun install && bun run dev
```

It runs at http://localhost:8040. `bun run build` writes the site to `website/dist/`, and `bun run check` checks the formatting (4-space indents) and lints it.
