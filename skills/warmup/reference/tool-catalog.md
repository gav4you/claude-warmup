# Tool catalog: what to install, by category, and from where

**Baseline** means install it for every web/app developer. **If** means install it only when the condition holds; scan the project manifests first. The Scoop bucket is `main` unless noted.

## 00 Terminal & shell (baseline, first)
| Tool | Source | When |
|---|---|---|
| Windows Terminal (upgrade + set as default terminal) | winget `Microsoft.WindowsTerminal` (MSIX), or the GitHub msixbundle | always |
| PowerShell 7 LTS | GitHub `PowerShell-<ver>-win-x64.msi` (checksum-verified) | always |
| PowerShell 7 current | winget `Microsoft.PowerShell` (MSIX) | optional, alongside the LTS |
Details: `terminal-shell.md`.

## 01 Go
| Tool | Source | When |
|---|---|---|
| go | `scoop install go` | baseline (Go users) |
| gopls, dlv, staticcheck, gofumpt, goimports, gotestsum, govulncheck | `go install`: golang.org/x/tools/gopls, github.com/go-delve/delve/cmd/dlv, honnef.co/go/tools/cmd/staticcheck, mvdan.cc/gofumpt, golang.org/x/tools/cmd/goimports, gotest.tools/gotestsum, golang.org/x/vuln/cmd/govulncheck | baseline |
| golangci-lint v2 | `go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest` | baseline |
| air | `go install github.com/air-verse/air@latest` | web servers |
| mockgen | `go install go.uber.org/mock/mockgen@latest` | if go.uber.org/mock is used |
| migrate | `go install -tags 'postgres pgx5 sqlite file github' github.com/golang-migrate/migrate/v4/cmd/migrate@latest` | if golang-migrate is used |
| goose | `go install github.com/pressly/goose/v3/cmd/goose@latest` (**NOT** `scoop install goose`) | if goose migrations are used |
| sqlc, templ | `go install` github.com/sqlc-dev/sqlc/cmd/sqlc, github.com/a-h/templ/cmd/templ | if used (sqlc needs cgo/gcc) |
| protoc-gen-go, protoc-gen-go-grpc, protoc-gen-connect-go, grpcurl | `go install` | if `*.proto` files exist |
| swag, goreleaser, river, wails | `go install` | if swaggo / `.goreleaser.yaml` / riverqueue / desktop apps |
| VS Code Go helpers: gomodifytags, impl, gotests, goplay | `go install` | if VS Code is used |
| golang.org/x commands | `scripts/golang-x-tools.ps1`: deadcode, stringer, gonew, modernize, benchstat, pkgsite, gomobile/gobind, tour… Skip x/build, vulndb, pkgsite-metrics and website servers (Google infrastructure), and golint/vgo/benchcmp (deprecated) | "everything plus more" |
| gcc for cgo | WinLibs MinGW-w64 (UCRT) or Scoop `mingw-winlibs` | if cgo is used (sqlite3, sqlc) |

## 02 JavaScript
| Tool | Source | When |
|---|---|---|
| Node LTS (even major) | winget `OpenJS.NodeJS.LTS` (system; MCP configs often hardcode its path) | baseline. Odd majors go EOL in ~8 months |
| fnm | `scoop install fnm`, `FNM_DIR=C:\DevTools\fnm`, `fnm default system` | baseline (per-project `.nvmrc`) |
| pnpm, typescript, eas-cli, wrangler, vercel | `npm i -g` | pnpm baseline; others if used. Node ≥25 no longer ships corepack |
| bun, deno, tailwindcss | `scoop install` | if used |

## 03 Mobile / Desktop
| Tool | Source | When |
|---|---|---|
| Android Studio + SDK | winget / official (SDK stays in `%LOCALAPPDATA%\Android\Sdk`) | Android/Expo/Flutter |
| Android cmdline-tools | Official zip from `repository2-3.xml`, checksum verified → `Sdk\cmdline-tools\latest`. Use the **`android` CLI** (`android sdk install ndk/<ver>`); `sdkmanager` is deprecated | Android |
| ANDROID_HOME, ANDROID_NDK_HOME, PATH (platform-tools, emulator, cmdline-tools\latest\bin) | user env | Android |
| JDK 21 | existing MSI or `scoop install java/microsoft21-jdk`. Put it FIRST on PATH, ahead of old Oracle `javapath` entries | Android/Kotlin |
| Flutter | official zip from `releases_windows.json` (SHA-256) → `C:\DevTools\sdk\flutter`, then `flutter config --android-sdk … --jdk-dir …` | if Flutter |
| kotlin, gradle | `scoop install kotlin gradle` | native Android |
| eas-cli (+ fastlane gem for iOS lanes) | npm -g / gem | Expo. Global `expo-cli` is deprecated; use `npx expo` |
| WebView2 | Evergreen runtime, or a fixed runtime through `WEBVIEW2_BROWSER_EXECUTABLE_FOLDER` | Wails/Tauri apps |
| upx, nsis | `scoop install` | Wails packaging |

## 04 Databases
| Tool | Source | When |
|---|---|---|
| PostgreSQL server | winget `PostgreSQL.PostgreSQL.18` with `--override "--mode unattended --superpassword <gen> --serverport 5432 --enable-components server,commandlinetools,pgAdmin --disable-components stackbuilder"`. Check port 5432 is free and write pgpass.conf | if the user wants a native server (otherwise Docker) |
| psql, pgcli | Client only: `scoop install postgresql` (latest major) or `versions/postgresql17` / `versions/postgresql16` to match the server (portable binaries; never run `pg_ctl`, so no service). With the native server: `C:\Program Files\PostgreSQL\<N>\bin` on PATH. Plus `uv tool install pgcli` | pgx/postgres users. Match the prod major |
| Docker Desktop | winget (system) | only with ≥30 GB free; the WSL2 VHDX grows by tens of GB |
| sqlite3, dbeaver, beekeeper-studio | `scoop install sqlite extras/dbeaver extras/beekeeper-studio` | baseline / GUI |

## 05 Containers & Cloud
Docker Desktop (winget; system). `scoop install gh extras/gcloud gitlab-runner`. AWS CLI, Azure CLI, kubectl, helm and Stripe go system or Scoop, as found. cloudflared: if it runs as a **service** backing a live site, upgrade only in a maintenance window. After moving gh, run `gh auth setup-git`.

## 06 API / Protobuf / HTTP
`scoop install protobuf buf xh k6 mkcert extras/bruno`; `uv tool install httpie`; grpcurl via go install.

## 07 CLI utilities (baseline)
`scoop install jq yq ripgrep fd fzf bat delta lazygit 7zip make just task gdu graphviz extras/everything extras/everything-cli`. Windows Terminal and PowerShell 7 are **not** from Scoop; see `terminal-shell.md` (do them first). Git for Windows stays system-installed (Claude Code's bash depends on it).

## 08 Security
`go install` gosec, osv-scanner, go-licenses, cyclonedx-gomod (govulncheck above); `scoop install trivy hadolint`.

## 09 Python / Ruby
| Tool | Source |
|---|---|
| Python | `scoop install versions/python3XY`. For a range like `>=3.12`, pick the **newest stable minor** the range allows unless a dependency is known to lag; otherwise ask. Pin the minor (e.g. `python312`, `python314`). Add `apps\python3XY\current` and `\Scripts` to PATH. Import `install-pep-514.reg` for `py`. Remove the Store `python.exe`/`python3.exe` aliases |
| Existing project venvs | Keep the interpreter they point to (`pyvenv.cfg` `home=`) until the user OKs a rebuild. Then run `uv venv --python 3.XY` and `uv sync` (or `pip install -r` from a saved `pip freeze`) |
| uv, ruff | `scoop install uv ruff` (uv tools then live in `scoop\persist\uv`) |
| Ruby | `scoop install msys2 versions/ruby33`. Set user env `MSYS2_PATH`, then `ridk install 2 3`; gems persist via `GEM_HOME` |

## 10 Editors
VS Code (winget user install) + extensions: golang.go, anthropic.claude-code, dbaeumer.vscode-eslint, esbenp.prettier-vscode, expo.vscode-expo-tools, Dart-Code.dart-code, Dart-Code.flutter, fwcd.kotlin, vscjava.vscode-gradle, ms-azuretools.vscode-containers, ms-vscode-remote.remote-wsl, redhat.vscode-yaml, tamasfe.even-better-toml, bufbuild.vscode-buf, bradlc.vscode-tailwindcss, a-h.templ, ms-python.python, charliermarsh.ruff, ms-ossdata.vscode-pgsql, Prisma.prisma, usernamehw.errorlens, EditorConfig.EditorConfig. Install them with `code --install-extension <id> --force`.

## Never
- `irm <random-url> | iex`. Download to a file, read it, then run it.
- A second copy of a toolchain (e.g. winget `GoLang.Go` next to Scoop Go).
- Registry cleaners.
- Chocolatey for new installs (it adds a third package manager).
