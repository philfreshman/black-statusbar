# Contributing to Nightbar

Thanks for helping out. This guide covers how branches work, how to build and test, and how to get a change merged.

## Branches

| Branch | What it is for |
| --- | --- |
| `main` | Released code only. Nobody pushes to it directly. It changes only by merging a pull request from `development`. |
| `development` | Day-to-day integration. All finished work lands here first. |
| `feat/…`, `fix/…`, `docs/…` | Short-lived branches for one change each, cut from `development`. |

## Workflow

1. Start from the latest `development`:

   ```bash
   git checkout development
   git pull
   git checkout -b feat/short-description
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

```bash
swift build
```

To build the full app bundle with its icon:

```bash
./scripts/build-app.sh
open "build/Nightbar.app"
```

## Test

```bash
swift test
```

Please make sure `swift build` and `swift test` both pass before you open a pull request.

## Commit messages

Use a short prefix that says what kind of change it is, followed by a summary in the imperative mood:

```
feat: add launch at login toggle
fix: keep the strip on screens added after launch
docs: explain the branch workflow
build: compile the app icon into the bundle
refactor: rename source folders to Nightbar
```

## Pull requests

- Keep each pull request to one change.
- Describe what changed and why, and how you tested it.
- Add a screenshot when the change is visible in the menu bar or the app's menu.

## App icon

The icon source is `Resources/AppIcon.icon`, an Icon Composer document. Edit it in Icon Composer (it ships with Xcode). Do not commit generated icon files; the build script compiles the icon.
