# Gotchas: real failures and their fixes

## Package managers
| Symptom | Cause | Fix |
|---|---|---|
| `winget show <id>` "found" but install says "No package found" | Loose matching on the output | Require a `^Version:` line. Kotlin → Scoop `kotlin`; Gradle → Scoop `gradle` |
| winget says "up to date" while an old version is installed | The app wasn't installed under that winget ID | Use the official installer, with SHA-256 from the release notes |
| winget MSIX installs fail with 0x80070422 | Delivery Optimization (DoSvc) disabled | Download the `.msixbundle` and run `Add-AppxPackage` |
| Scoop install looks "failed" in captured output | Scoop prints success through Write-Host (stream 6) | Use `scoop install x 6>&1`, or verify with `scoop export` |
| `scoop install goose` | That's Block's AI agent | `go install github.com/pressly/goose/v3/cmd/goose@latest` |
| `scoop` not found right after install | The current process PATH is stale | `$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')` |
| Bulk uninstall/install collides | Windows Installer handles one MSI at a time; other sessions may be running uninstallers | Check `msiexec` processes and MsiInstaller events 1040/1042; wait |

## Toolchains
| Symptom | Cause | Fix |
|---|---|---|
| Git installer exits 1, "Failed to proceed… aborting" | Orphan `tail`/`grep` from `C:\Program Files\Git\usr\bin` still running | Stop those processes; rerun with `/VERYSILENT /LOG=…` |
| `bun upgrade` → "Failed to verify Bun (FileNotFound)" | Broken self-update | Use Scoop `bun` (or the GitHub zip with SHASUMS256.txt) |
| `sdkmanager --licenses` is a no-op | The new Android CLI replaced it | Use `android sdk list --all` and `android sdk install ndk/<ver>`; then `gomobile init` |
| `wails doctor`: WebView2 missing | It only checks the Evergreen registry key | It's fine when `WEBVIEW2_BROWSER_EXECUTABLE_FOLDER` points to a fixed runtime |
| `java` is the wrong JDK | Old Oracle `javapath` sits earlier in machine PATH | Move the JDK 21 `bin` first, or remove the dead/old javapath |
| pnpm jumps a major version on `npm i -g pnpm@latest` | latest = new major | Install `pnpm@<packageManager major>`, or warn the user (lockfile prompts) |
| Go silently downloads toolchains into the module cache | `GOTOOLCHAIN=auto` plus a go.mod `go`/`toolchain` line newer than local Go | Install a local Go ≥ the highest pin first, then the tools |
| New Go/Python ignored after install | The old MSI's machine PATH entry comes first | Uninstall the MSI (when idle), then rebuild PATH |
| Scoop installer refuses to run | Execution policy, or an admin shell | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`; add `-RunAsAdmin` in elevated shells |

## Python / Ruby
| Symptom | Cause | Fix |
|---|---|---|
| `python` opens the Microsoft Store | App-execution alias stubs | Delete `%LOCALAPPDATA%\Microsoft\WindowsApps\python.exe`/`python3.exe` (or turn them off in Settings) |
| Scoop `versions/python314` has no `python` command | It only shims `python3`/`python314` | Add `apps\python314\current` and `\Scripts` to user PATH |
| venv/uv tool breaks after moving or uninstalling Python | `pyvenv.cfg` hardcodes the interpreter path | Recreate the venv. uv tools need `uv tool uninstall x` then `uv tool install x --python <new>` (`--reinstall` keeps the old path) |
| uv tools "disappear" after switching to Scoop uv | Scoop sets `UV_TOOL_DIR` etc. to `persist\uv` | Reinstall them. Delete the old shims in `~\.local\bin` but **not `claude.exe`** |
| Gems "installed" but the launcher can't find them | Old Ruby earlier on PATH, or GEM_HOME not set during install | Use explicit Scoop Ruby paths; a clean reinstall gives a pristine versioned folder |
| "MSYS2 could not be found" | RubyInstaller ignores `RI_DEVKIT` | Set user env `MSYS2_PATH=C:\DevTools\scoop\apps\msys2\current` |
| `Could not find 'multi_json'` at fastlane runtime | A transitive gem wasn't resolved | Loop: run the tool and `gem install` whatever it names |

## Moving things
| Symptom | Cause | Fix |
|---|---|---|
| GitHub pushes ask for credentials after moving gh | The git credential helper hardcodes gh's path | `git config --global --unset-all credential.https://github.com.helper` then `gh auth setup-git` |
| A Start Menu shortcut or env var points at a moved folder | Other tools hardcode paths | Grep `.lnk` targets and env vars before moving; repoint after |
| Docker containers down after reboot | Docker Desktop `AutoStart=false`; `restart=no` containers don't return | Record `docker ps` before upgrades/reboots and restart that list |
| cloudflared/service-backed tools | Upgrading restarts the service and takes a live site down | Check what the service serves before upgrading |

## Claude Code harness
| Symptom | Cause | Fix |
|---|---|---|
| "Remove-Item on system path … is blocked" | The guard blocks `C:\Windows\*` and drive-root folders. It misreads `/s`, `/y`, `\d`, `'\'` and `$var`-built paths, and anything sharing a command with `Get-PSDrive C` | Put the removal in its own command with literal user-profile paths. For system paths, give the user `! rm -f "/c/…"` (the `!` prompt runs **bash**, not PowerShell) |
| Disk Cleanup won't remove LiveKernelReports | cleanmgr only handles MEMORY.DMP and minidumps | The user deletes them manually |
| A `Start-Sleep 5` takes minutes | The disk is near-full or heavy scans are running | Fix the disk first; stop runaway scans |
