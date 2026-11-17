# Warmup: quick manual

What gets set up on your Windows machine, why, and how to keep it healthy. About a five-minute read.

## The idea in one paragraph

Every developer tool lives in **one folder, `C:\DevTools`**, sorted into category folders with shortcuts and a `catalog.json` index. Tools come from **trusted sources** with checksums checked, not random installers. A few things need deep Windows integration and stay installed the normal way: the terminal, PowerShell, Docker, databases, Git and the system Node. Nothing gets replaced while your work or AI agents are running.

## What gets installed, and why

| Category | Main tools | What they're for |
|---|---|---|
| **Terminal & shell** | Windows Terminal (set as default), PowerShell 7 LTS (+ current) | A modern console where copy/paste works and tabs exist; the shell every script and Claude Code session uses |
| **Package managers** | Scoop (into `C:\DevTools\scoop`) | Installs portable tools into one folder, updates them with one command, and leaves no registry mess |
| **Go** | Go, gopls, dlv, golangci-lint, staticcheck, air, migration and codegen tools | Build, debug, lint, hot-reload and generate code for Go services |
| **JavaScript** | Node LTS, pnpm, fnm, Bun, Deno, TypeScript | Web front-ends and tooling; fnm switches Node versions per project |
| **Mobile & desktop** | Android Studio + SDK, Flutter, Kotlin, Gradle, Expo/EAS, Wails | Android/iOS apps (iOS builds run in the cloud through EAS) and Go desktop apps |
| **Databases** | PostgreSQL (server or client), psql/pgcli, SQLite, DBeaver/Beekeeper | Local databases and GUIs to inspect them |
| **Containers & cloud** | Docker Desktop, gh, gcloud/aws/az, kubectl/helm, wrangler | Containers, GitHub, and cloud deployments |
| **APIs** | protoc/buf, grpcurl, httpie/xh, k6, Bruno, mkcert | Protobuf/gRPC, HTTP testing, load tests, local HTTPS |
| **Everyday CLI** | ripgrep, fd, fzf, jq/yq, bat, delta, lazygit, make/just/task, 7-Zip, Everything | Fast search, JSON/YAML, nicer diffs, task runners, instant file search |
| **Security** | govulncheck, gosec, trivy, osv-scanner, hadolint | Find vulnerable dependencies and risky code before shipping |
| **Python & Ruby** | Python + uv + ruff, Ruby + MSYS2 (for fastlane) | Scripts and services; fastlane automates app-store releases |
| **Editor** | VS Code + extensions (Go, Claude Code, ESLint, Prettier, Flutter…) | One editor that understands every stack above |

Only what your projects actually use is installed beyond the baseline. Claude reads your `go.mod`, `package.json`, `pyproject.toml` and similar files first.

## Best practices

1. **One home for tools.** If it can be portable, it goes in `C:\DevTools`. Don't scatter installers across Program Files and AppData.
2. **Trusted sources only.** Use Scoop, the language's own installer (`go install`, `npm -g`, `uv tool`), or an official download with its checksum verified. Never paste a `… | iex` command from a web page.
3. **Keep 30 GB free.** Builds, Docker and SDKs need room, and a full disk can corrupt databases. GPU-driver crash dumps can eat 25 GB at a time, so keep your graphics driver updated.
4. **Don't swap tools under running work.** Upgrade Go, Node, Git or Python only when your agents, builds and containers are idle. Until then, stage the new version side by side.
5. **One copy of each tool.** Two Gos or two Pythons on PATH cause "works here, fails there" bugs. `where.exe go` should print one line.
6. **Back up before system changes.** Save PATH to a file and `reg export` a key before editing it. No registry cleaners, ever.
7. **Pin versions per project.** Use `.nvmrc`, the `packageManager` field, `requires-python` and go.mod `toolchain`, so every machine builds the same way.
8. **Update on a rhythm.** Monthly, when idle: `scoop update *`, rebuild the Go tools, `npm i -g pnpm eas-cli wrangler`, `uv tool upgrade --all`, `flutter upgrade`. Then refresh the catalog.
9. **Verify in a fresh terminal.** Open a new window after any change and run a quick build. "Installed" isn't the same as "works".
10. **Write it down.** The catalog, a short handoff note and Claude's memory notes mean the next person (or the next Claude session) knows what's there.

## Where things are

| Path | What |
|---|---|
| `C:\DevTools\README.md`, `catalog.json` | The index of every tool |
| `C:\DevTools\01-Go` … `10-Editors-IDEs` | Shortcuts by category |
| `C:\DevTools\scoop` | Scoop apps (`apps\<name>\current`) |
| `C:\DevTools\gopath\bin` | Go tools |
| `C:\DevTools\_scripts` | Rebuild catalog, reinstall Go tools, disk sizing |
| `C:\Program Files\PowerShell\7` | PowerShell 7 LTS, used by scheduled tasks |
