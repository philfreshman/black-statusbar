# Contributing to Nightbar

Thanks for helping out. This guide covers how branches work, how to build and test, and how to get a change merged.

## Branches

| Branch | What it is for |
| --- | --- |
| `main` | Released code only. Nobody pushes to it directly. It changes only by merging a pull request from `development`. |
| `development` | Day-to-day integration. All finished work lands here first. |
| `feat/…`, `fix/…`, `chore/…`, … | Short-lived branches for one change each, cut from `development`. |

### Branch names

Every working branch has a type prefix and a short, meaningful name in lowercase kebab-case:

```
<type>/<short-description>
```

| Prefix | Use it for |
| --- | --- |
| `feat/` | A new feature |
| `fix/` | A bug fix |
| `chore/` | Maintenance, tooling, repo housekeeping |
| `update/` | Updating something that exists, such as dependencies or assets |
| `docs/` | Documentation only |
| `refactor/` | Restructuring code without changing behaviour |
| `build/` | Build scripts and packaging |
| `test/` | Adding or fixing tests |

Good: `feat/launch-at-login`, `fix/strip-on-new-screen`, `chore/contributing-guide`.
Not allowed: names without a prefix (`my-branch`), tool-generated names (`claude/…`, `copilot/…`), or vague names (`fix/stuff`, `feat/wip`).

A check on every pull request enforces this. Pull requests into `main` must come from `development`.

## Workflow

1. Start from the latest `development`:

   ```bash
   git checkout development
   git pull
   git checkout -b feat/short-description   # see Branch names
   ```

2. Make your change in small, focused commits.
3. Build and test locally (see below).
4. Push your branch and open a pull request **into `development`**.
5. Once reviewed, it is merged into `development`.

When `development` is ready for a release, a maintainer opens a pull request from `development` into `main`. Merging that pull request is the only way code reaches `main`.

## Requirements

- macOS 14 or later
- Xcode 26 or later (the build uses Xcode's `actool` to compile the app icon)

Nightbar uses AppKit, so it builds and tests only on a Mac.

## Build

Nightbar compiles in Swift 6 language mode, so the compiler checks data-race safety: code that could touch the same state from two threads at once does not build. Keep the build free of warnings too. Build with warnings treated as errors, for the app and for the tests:

```bash
swift build -Xswiftc -warnings-as-errors
swift build --build-tests -Xswiftc -warnings-as-errors
```

The flag is passed on the command line rather than set in `Package.swift`, which stays free of unsafe flags.

Mark AppKit and other UI code `@MainActor`, and make values that cross actors `Sendable`. Use `MainActor.assumeIsolated` only where AppKit guarantees the main thread. Avoid `nonisolated(unsafe)` and `@unchecked Sendable`; if one is truly needed, add a comment that says why it is safe.

To build the full app bundle with its icon:

```bash
./scripts/build-app.sh
open "build/Nightbar.app"
```

## Test

```bash
swift test
```

## Format

The Swift code is formatted with `swift format`, which ships with the Swift toolchain. Its settings are in `.swift-format` at the repo root.

```bash
swift format format --in-place --recursive Sources Tests Package.swift   # format the code
swift format lint --strict --recursive Sources Tests Package.swift       # check formatting and style
```

## Lint

The Swift code is linted with [SwiftLint](https://github.com/realm/SwiftLint), which looks for risky patterns such as force unwrapping and keeps functions, types and files small. Install it with `brew install swiftlint`. Its settings are in `.swiftlint.yml` at the repo root; `Tests/.swiftlint.yml` relaxes a rule for the tests. SwiftLint leaves layout to `swift format`, so the two never disagree.

```bash
swiftlint lint --strict
```

## Dead code

[Periphery](https://github.com/peripheryapp/periphery) finds unused code: declarations, parameters, properties that are set but never read, and imports. Install it with `brew install periphery`. Its settings are in `.periphery.yml` at the repo root. Periphery reads the index that `swift build` writes while it compiles, so build the tests first; the tests count as users of the code.

```bash
swift build --build-tests && periphery scan
```

When Periphery reports code that is in fact used, for example a method only AppKit calls, prefer a setting in `.periphery.yml` over a `// periphery:ignore` comment, and give the comment a short reason when you need one.

## Duplication

[jscpd](https://github.com/kucherenko/jscpd) finds copied blocks of code in `Sources` and `Tests`. It runs with [Bun](https://bun.sh), so there is nothing to install besides Bun. Its settings are in `.jscpd.json` at the repo root, and it fails on any copied block of 50 tokens and 5 lines or more.

```bash
bunx jscpd@5.4.3
```

Please make sure the build with warnings as errors, `swift test`, both lint checks and the dead code and duplication checks pass before you open a pull request.

## Website

The landing page at [nightbar.app](https://nightbar.app) lives in `website/`: a [Vite+](https://viteplus.dev) project using [Bun](https://bun.sh), TypeScript and plain CSS. The page is written as small TypeScript modules in `website/src/sections/` and rendered into `index.html` at build time, so it ships as static HTML. Vercel deploys it with `website` as the project's root directory.

```bash
cd website
bun install
bun run dev     # http://localhost:8040
bun run check   # format, lint and type check
bun run fallow  # unused code, duplication and complexity
bun run test
bun run build   # writes website/dist/
```

## Releases

Releases are built by GitHub Actions (`.github/workflows/release.yml`). After `development` has been merged into `main`, tag the merge commit on `main` and push the tag:

```bash
git checkout main && git pull
git tag v1.0.0
git push origin v1.0.0
```

The workflow tests and builds the app, sets the version from the tag and publishes `Nightbar.zip` on a GitHub release. The website's download button and `https://nightbar.app/download` always point at the latest release. The app is signed ad hoc, not notarized.

## Commit messages

Use a short prefix that says what kind of change it is, followed by a summary in the imperative mood:

```
feat: add launch at login toggle
fix: keep the strip on screens added after launch
docs: explain the branch workflow
build: compile the app icon into the bundle
refactor: rename source folders to Nightbar
```

## Commit authorship

Commits must be tied to the human contributor who owns the change, never to an AI agent or tool. When an agent writes the commit, it uses the contributor's own git identity.

Do not add agent attribution to commits or pull requests: no `Co-Authored-By` trailers for an agent, no session links, and no "Generated with ..." footers.

## Pull requests

- Keep each pull request to one change.
- Describe what changed and why, and how you tested it.
- Add a screenshot when the change is visible in the menu bar or the app's menu.

## App icon

The icon source is `Resources/AppIcon.icon`, an Icon Composer document. Edit it in Icon Composer (it ships with Xcode). Do not commit generated icon files; the build script compiles the icon.
