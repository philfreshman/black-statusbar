# AGENTS.md

Nightbar is a small macOS 14+ menu bar app that makes the menu bar black with white icons. It puts a black borderless strip behind each screen's menu bar, just above the wallpaper, so macOS draws a dark menu bar with white icons.

Swift Package (tools 6.0, Swift 5 language mode), AppKit, no dependencies. It builds and tests only on macOS with Xcode 26 or later.

## Layout

- `Sources/Nightbar/` — executable entry point (`main.swift`).
- `Sources/NightbarCore/` — app logic: overlay window, status menu, screen geometry, launch at login.
- `Tests/NightbarCoreTests/` — tests (swift-testing).
- `Resources/` — `Info.plist` and the `AppIcon.icon` Icon Composer source.
- `scripts/build-app.sh` — builds `build/Nightbar.app` and compiles the icon.
- `website/` — the nightbar.app landing page: Vite+ with Bun, TypeScript and plain CSS. Sections are TypeScript modules in `website/src/sections/`, rendered into `index.html` at build time; one CSS file per section in `website/src/styles/`. Run `bun run check`, `bun run test` and `bun run build` there (formatting: 4-space indents, single quotes, no semicolons, via `vp fmt`).
- `.github/workflows/` — release and branch-name checks.

## Build and test

```bash
swift build
swift test
./scripts/build-app.sh   # full app bundle at build/Nightbar.app
```

Branching, commit and pull request rules are in [CONTRIBUTING.md](CONTRIBUTING.md).
