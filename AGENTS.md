# AGENTS.md

Guidance for AI coding agents working in this repository. Read [CONTRIBUTING.md](CONTRIBUTING.md) for the full workflow; the rules below are the ones agents most often get wrong.

## Project

Nightbar is a small macOS 14+ menu bar app written in Swift (Swift Package, AppKit, no dependencies). It builds and tests only on a Mac.

```bash
swift build               # build
swift test                # run tests
./scripts/build-app.sh    # build build/Nightbar.app with its icon
```

## Commits

- Commit as the user, never as the agent. Set author and committer to:

  ```bash
  git config user.name  "philfreshman"
  git config user.email "61979403+philfreshman@users.noreply.github.com"
  ```

- Do not add agent attribution anywhere: no `Co-Authored-By` trailers, no session links, no "Generated with ..." footers, in commit messages or pull request descriptions.
- Use the commit message prefixes from CONTRIBUTING.md (`feat:`, `fix:`, `docs:`, `build:`, ...).

## Branches and pull requests

- Name branches `<type>/<short-description>`, for example `feat/…`, `fix/…`, `chore/…`, `update/…`. Never use `claude/…` or other tool-generated names.
- Branch from `development` and open pull requests into `development`.
- Never push to `main`. It changes only by merging a pull request from `development`.
