---
name: warmup
description: Use when someone starts using Claude Code on a new or unfamiliar Windows machine, asks what developer tools they need, wants a dev environment set up, audited, upgraded or organized, says tools are missing or outdated, or installs fail because the disk is nearly full or tools are scattered across winget, MSI, Chocolatey and Program Files.
---

# Warmup: dev machine setup frame of reference

## Overview

Set a machine up so every dev tool lives in **one folder (`C:\DevTools`)**, comes from a **verifiable source**, and is **cataloged by category**. Never break work that is already running.

**Core principle:** inventory → health gate → plan from what the code uses → install by source priority → organize → verify from a fresh PATH. Never install blind, and never declare done without a fresh-shell check.

Windows-specific. On macOS/Linux the phases still apply; swap Scoop for Homebrew or mise. Bundled files live next to this SKILL.md, in `scripts/` and `reference/` (normally `~\.claude\skills\warmup\`). The scripts run in Windows PowerShell 5.1 (`powershell -File …`) or pwsh 7.

## The phases

1. **Read context first.** Check memory/notes, the user's CLAUDE.md, and the repos.
   - Detect stacks: `go.mod`, `package.json`, `pubspec.yaml`, `app.json`/`eas.json`, `pyproject.toml`, `Gemfile`, `*.proto`, `Makefile`, `Taskfile.yml`, `.golangci.yml`.
   - Read **version pins**: go.mod `go`/`toolchain`, `packageManager`/`engines`/`.nvmrc`, `requires-python`, existing `.venv`s, the prod Postgres major.
   - Ask only what files can't answer: editor, mobile/desktop targets, native vs Docker DB, what may be deleted, where reports go.
2. **Inventory (read-only).** First run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` (fresh machines block scripts), then `powershell -File scripts\inventory.ps1`. It covers tools, versions, duplicates across folders, dead PATH entries, disk, running agent/build processes, Docker and Store aliases.
3. **Health gate.**
   - Disk: under ~30 GB free means recover space **before** installing; see `reference/disk-recovery.md`. The ~5 MB Everything search tool is the one allowed install, because it's how you find the space.
   - Running work: agent loops, `go`/`node` builds or containers mean you **stage side-by-side and swap only when idle**. **Idle** means the user confirms other sessions are stopped (loops have gaps between runs, so a process snapshot alone can lie) *and* `Get-Process go,gopls,node,claude,codex,msiexec` shows nothing outside your own shell's process tree (`$PID` and its children). Never decide it alone. Staging installs are fine while busy. Uninstalling MSIs, `go env -w`, moving GOPATH and rebuilding venvs wait.
4. **Plan.** Pick tools from `reference/tool-catalog.md` by what the manifests import and pin, plus the baseline set. Show the plan. Get a yes for anything system-level, destructive, or that replaces a toolchain.
5. **Install by source priority** (table below). Verify every manual download's checksum against the publisher's list. Install Go tools **after** any Go swap, since GOTOOLCHAIN=auto otherwise pulls extra toolchains.
6. **Organize.** Use the `C:\DevTools` layout in `reference/layout.md`. Move portable SDKs with a junction left at the old path. Run `scripts\build-catalog.ps1` to generate category shortcut folders plus `README.md` and `catalog.json`.
7. **Verify.** Rebuild PATH from the registry. Check that `where.exe <tool>` gives exactly one intended location, then run smoke tests (go build + lint, `pnpm install --frozen-lockfile`, `uv run pytest`, `flutter doctor`, `gh auth status`, DB query). Confirm no dead PATH entries. Write a handoff in the user's docs location (ask if unknown) and save memory notes on what's staged or pending.

## Source priority

| Need | Source |
|---|---|
| CLI tools, GUIs, SDKs without services | **Scoop**, root `C:\DevTools\scoop` (buckets: main, extras, versions, java) |
| Go tools | `go install <pkg>@latest` → GOBIN `C:\DevTools\gopath\bin` |
| JS CLIs | `npm i -g` on the system Node (pnpm pinned to `packageManager`'s major, eas-cli, wrangler). They land in `%APPDATA%\npm` on purpose, alongside the system Node |
| Python CLIs | `uv tool install` |
| Ruby gems | `gem install` on Scoop Ruby (+ msys2) |
| Not in Scoop | Official release zip + SHA-256 check → `C:\DevTools\sdk\` or `portable\` |
| Windows services, drivers, deep integration | winget/MSI: Docker Desktop, PostgreSQL server, Git for Windows, system Node, VS Code, Android Studio, VS Build Tools |

## Red flags: stop and re-check

- You're about to recursively scan a full disk. Use Everything/es (MFT, seconds), not gdu/robocopy (minutes, and they compete for I/O).
- You're replacing Go, Node or Git, running `go env -w`, moving GOPATH/GOCACHE, or clearing `go-build`/`npm-cache\_npx` while those processes run. `go env -w` is global, so a running loop's next `go` call picks it up. Upgrading Git breaks live Claude sessions, whose Bash *is* Git Bash.
- An old MSI install (Go/Python/Node) is still on the **machine** PATH. Machine PATH is searched before user PATH, so it shadows the new copy until it's uninstalled.
- A winget "found" check didn't print a `Version:` line.
- `scoop install goose`: that's Block's AI agent. Migrations are `go install github.com/pressly/goose/v3/cmd/goose@latest`.
- You moved a Python install or a project that has a venv. venvs hardcode paths, so recreate them.
- You're about to say "done" without running commands from a freshly built PATH.

## Common mistakes

See `reference/gotchas.md`: every real failure from the first run, with its fix (Scoop output capture, Store python alias, uv tool dir, Ruby `GEM_HOME`/`MSYS2_PATH`, gh credential helper, Git installer locks, WebView2, Claude's Remove-Item guard, and more).

## Maintenance

`scoop update *` · `scripts/go-tools.ps1` · `scripts/golang-x-tools.ps1` · `npm i -g pnpm eas-cli wrangler` · `uv tool upgrade --all` · `flutter upgrade` · `scripts/build-catalog.ps1`
