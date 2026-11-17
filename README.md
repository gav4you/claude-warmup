# warmup: a dev-machine setup skill for Claude Code

When you start using Claude Code on a Windows machine, `warmup` tells Claude:
- **what to install** for web and app development (Go, Node/pnpm, Python, Ruby, Flutter, Expo, Android, databases, cloud CLIs, editors)
- **which source to install each tool from**
- **how to organize it all** in one folder, `C:\DevTools`, with category shortcuts and a generated `catalog.json`

It also tells Claude how to do this without breaking work that's already running: agent loops, builds and containers. And it lists the pitfalls that actually happened on a real setup.

## Install

In Claude Code:

```
/plugin marketplace add gav4you/claude-warmup
/plugin install warmup@claude-warmup
```

Then just ask, for example: *"set up my machine for Go and web development"* or *"audit my dev tools and organize them"*. The skill triggers on requests like these.

**New to all this?** Read [`skills/warmup/MANUAL.md`](skills/warmup/MANUAL.md), a five-minute guide to what gets installed, why, and the best practices.

## What's inside

```
skills/warmup/
├─ SKILL.md                 eight phases, source priority, red flags
├─ MANUAL.md                plain-language guide: what gets installed and best practices
├─ reference/
│  ├─ terminal-shell.md     Windows Terminal as default, PowerShell 7 LTS (+ current), profiles: do first
│  ├─ tool-catalog.md       what to install per category, the exact source, and when
│  ├─ layout.md             C:\DevTools layout; how to migrate from winget/MSI to Scoop safely
│  ├─ disk-recovery.md      find space in seconds (Everything/MFT); what's safe to delete
│  └─ gotchas.md            real failures and their fixes
└─ scripts/
   ├─ inventory.ps1         read-only audit: tools, duplicates, dead PATH entries, disk, running work
   ├─ build-catalog.ps1     category shortcut folders + README.md + catalog.json
   ├─ go-tools.ps1          (re)install the Go toolset @latest
   ├─ golang-x-tools.ps1    developer-facing golang.org/x commands
   └─ dirsize.ps1, essize.ps1   folder sizing helpers
```

## Principles

1. **Take an inventory before installing anything.**
2. **Recover disk space first** if C: has less than ~30 GB free.
3. **Fix the foundation:** make Windows Terminal the default terminal (paste breaks in the old console) and install PowerShell 7 LTS.
4. **Pick tools by what your code uses.** Read the go.mod, package.json and pyproject files, including their version pins.
5. **Source priority:**
   - Scoop, rooted at `C:\DevTools\scoop`
   - language-native tools: `go install`, `npm -g`, `uv tool`, `gem`
   - an official release zip with its SHA-256 checked
   - winget/MSI only for services and deep Windows integration
6. **Stage changes while work is running.** Swap toolchains only when the user confirms things are idle.
7. **Verify from a fresh PATH.** Each `where.exe <tool>` should resolve exactly once, then run smoke tests.

Windows-focused. On macOS or Linux the same phases apply with Homebrew or mise.

## License

MIT
