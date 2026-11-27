# AGENTS.md

Nightbar is a small macOS 14+ menu bar app that makes the menu bar black with white icons. It puts a black borderless strip behind each screen's menu bar, just above the wallpaper. On light wallpapers macOS still tints the bar grey and may draw black text, so a contrast window over the menu bar remaps its colours to black with white text (`ColorRemap`, `ColorRemapView`, which uses private Core Animation classes). Nightbar's own status item reports whether macOS draws the menu bar light or dark (`MenuBarAppearanceWatcher`). Each screen gets one set of these windows per Space (`ScreenOverlay`), made the first time the Space becomes active, so they slide with the Space during a swipe; full-screen Spaces are skipped (`FullScreenDetection`).

Swift Package (tools 6.0, Swift 6 language mode, so the compiler checks data-race safety), AppKit, no dependencies. It builds and tests only on macOS with Xcode 26 or later.

## Layout

- `Sources/Nightbar/` — executable entry point (`main.swift`).
- `Sources/NightbarCore/` — app logic: overlay window, status menu, screen geometry, launch at login.
- `Tests/NightbarCoreTests/` — tests (swift-testing).
- `Resources/` — `Info.plist` and the `AppIcon.icon` Icon Composer source.
- `scripts/build-app.sh` — builds `build/Nightbar.app` and compiles the icon.
- `website/` — the nightbar.app landing page: Vite+ with Bun, TypeScript and plain CSS. Sections are TypeScript modules in `website/src/sections/`, rendered into `index.html` at build time; one CSS file per section in `website/src/styles/`. Run `bun run check`, `bun run fallow` (dead code, duplication and complexity), `bun run test` and `bun run build` there (formatting: 4-space indents, single quotes, no semicolons, via `vp fmt`).
- `.github/workflows/` — release and branch-name checks.

## Build and test

```bash
swift build -Xswiftc -warnings-as-errors                 # build; any warning fails it
swift build --build-tests -Xswiftc -warnings-as-errors   # same for the tests
swift test
./scripts/build-app.sh   # full app bundle at build/Nightbar.app
swift format format --in-place --recursive Sources Tests Package.swift   # format (config: .swift-format)
swift format lint --strict --recursive Sources Tests Package.swift       # check formatting
swiftlint lint --strict   # lint (config: .swiftlint.yml, Tests/.swiftlint.yml; install: brew install swiftlint)
swift build --build-tests && periphery scan   # dead code (config: .periphery.yml; install: brew install periphery)
bunx jscpd@5.4.3   # duplication (config: .jscpd.json; runs with Bun)
```

Keep the build free of warnings. Package.swift stays free of unsafe flags, so `-warnings-as-errors` is passed on the command line. For concurrency, isolate AppKit and UI code to the main actor with `@MainActor` and make values that cross actors `Sendable`. Use `MainActor.assumeIsolated` only where AppKit guarantees the main thread, and avoid `nonisolated(unsafe)` and `@unchecked Sendable`; when one is truly needed, give it a comment with the reason.

SwiftLint leaves layout to swift-format, so its layout rules stay off. Fix findings in the code; use `// swiftlint:disable:next <rule>` only with a short reason.

Periphery reads the index at `.build/out`, where SwiftPM's swift-build writes it, so build the tests before scanning. Remove dead code it finds; for code that is in fact used, prefer a setting in `.periphery.yml` over `// periphery:ignore`, and give the comment a short reason. jscpd fails on any copied block; extract the shared code instead of raising its limits.

Branching, commit, code style and pull request rules are in [CONTRIBUTING.md](CONTRIBUTING.md).
