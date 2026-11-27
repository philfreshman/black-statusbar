# AGENTS.md

Nightbar is a small macOS 14+ menu bar app that makes the menu bar black with white icons. It puts a black borderless strip behind each screen's menu bar, just above the wallpaper. On light wallpapers macOS still tints the bar grey and may draw black text, so a contrast window over the menu bar remaps its colours to black with white text (`ColorRemap`, `ColorRemapView`, which uses private Core Animation classes). Nightbar's own status item reports whether macOS draws the menu bar light or dark (`MenuBarAppearanceWatcher`). Each screen gets one set of these windows per Space (`ScreenOverlay`), made the first time the Space becomes active, so they slide with the Space during a swipe; full-screen Spaces are skipped (`FullScreenDetection`).

Swift Package (tools 6.0, Swift 6 language mode, so the compiler checks data-race safety), AppKit, no dependencies. It builds and tests only on macOS with Xcode 26 or later.

## Layout

- `Sources/Nightbar/` — executable entry point (`main.swift`).
- `Sources/NightbarCore/` — app logic: overlay window, status menu, screen geometry, launch at login.
- `Tests/NightbarCoreTests/` — tests (swift-testing).
- `Resources/` — `Info.plist` and the `AppIcon.icon` Icon Composer source.
- `scripts/build-app.sh` — builds `build/Nightbar.app` and compiles the icon.
- `scripts/find-dead-code.sh` — finds unused code with `swiftlint analyze`.
- `website/` — the nightbar.app landing page: Vite+ with Bun, TypeScript and plain CSS. Sections are TypeScript modules in `website/src/sections/`, rendered into `index.html` at build time; one CSS file per section in `website/src/styles/`. Run `bun run check`, `bun run fallow` (dead code, duplication and complexity), `bun run test` and `bun run build` there (formatting: 4-space indents, single quotes, no semicolons, via `vp fmt`).
- `.github/workflows/` — release, branch-name checks, the website checks, and `swift.yml`, which runs every Swift check (build with warnings as errors, tests, `swift format`, SwiftLint, dead code via `swiftlint analyze`, jscpd) on every pull request and on pushes to `development`. `.github/actions/select-xcode` switches the macOS runner to its newest stable Xcode.

## Build and test

```bash
swift build -Xswiftc -warnings-as-errors                 # build; any warning fails it
swift build --build-tests -Xswiftc -warnings-as-errors   # same for the tests
swift test
./scripts/build-app.sh   # full app bundle at build/Nightbar.app
swift format format --in-place --recursive Sources Tests Package.swift   # format (config: .swift-format)
swift format lint --strict --recursive Sources Tests Package.swift       # check formatting
swiftlint lint --strict   # lint (config: .swiftlint.yml, Tests/.swiftlint.yml; install: brew install swiftlint)
./scripts/find-dead-code.sh   # dead code: clean verbose build, then swiftlint analyze (analyzer_rules in .swiftlint.yml)
bunx jscpd@5.4.3   # duplication (config: .jscpd.json; runs with Bun)
```

Keep the build free of warnings. Package.swift stays free of unsafe flags, so `-warnings-as-errors` is passed on the command line. For concurrency, isolate AppKit and UI code to the main actor with `@MainActor` and make values that cross actors `Sendable`. Use `MainActor.assumeIsolated` only where AppKit guarantees the main thread, and avoid `nonisolated(unsafe)` and `@unchecked Sendable`; when one is truly needed, give it a comment with the reason.

SwiftLint leaves layout to swift-format, so its layout rules stay off. Fix findings in the code; use `// swiftlint:disable:next <rule>` only with a short reason.

`swiftlint analyze` reads compiler arguments from a verbose build log and skips files missing from it, so `scripts/find-dead-code.sh` always builds from scratch in a temporary folder. Remove dead code it finds; name parameters a protocol or override fixes but you don't read `_`; for code that is in fact used, use `// swiftlint:disable:next unused_declaration` with a short reason. jscpd fails on any copied block; extract the shared code instead of raising its limits.

Branching, commit, code style and pull request rules are in [CONTRIBUTING.md](CONTRIBUTING.md).
