# Disk recovery before installing

## Find the space fast
Everything (~5 MB) is the only install allowed before space is recovered. Without Scoop, use the voidtools portable zip.
1. Run `scoop install extras/everything extras/everything-cli`. In Everything.ini set `app_data=0` and `index_folder_size=1`, then run `everything -install-service` and `everything -startup`.
2. Top folders: `es /ad -size -sort size-descending -parent <dir>`. This is instant once indexed. Avoid `es -path` (it's slow) and recursive PowerShell/robocopy/gdu walks, which take minutes and fight live sessions for I/O.
3. Largest files: `es -n 25 -size -sort size-descending file:`. Virtual disks: `es -size -sort size-descending "ext:vhdx;vhd;vdi;vmdk;qcow2;iso;img;wim" size:>100mb`.
4. Don't use WizTree. Its EULA is personal-use only, while Everything is MIT.

## Usual culprits (Windows dev box)
| Path | Typical | Safe? |
|---|---|---|
| `C:\Windows\LiveKernelReports\*.dmp`, `C:\Windows\ServiceProfiles\LocalService\AppData\Local\Temp\*.dmp` | 20–30 GB each (GPU driver hang dumps) | Yes; the user deletes them (the harness blocks system paths). Fix the driver too |
| `%TEMP%` files older than 3 days | GBs, runaway logs | Yes. **Exclude `%TEMP%\claude\`** (live Claude sessions) and `*.vhdx` (WSL swap) |
| npm `_cacache` | GBs | Yes. **Never `_npx`**: running MCP servers execute from it |
| `~\.gradle\caches`, old Playwright `ms-playwright\<browser>-<rev>` | GBs | Yes. Keep the newest revisions and any a running test uses |
| Discontinued Windows Subsystem for Android, minikube cache | ~3 GB | Yes (`Remove-AppxPackage`) |
| `Dism /Online /Cleanup-Image /StartComponentCleanup` | 1–5 GB | Yes (no `/ResetBase`) |
| Go build cache | 5–15 GB | Ask; not while builds run |
| Docker VHDX, `.codex`/`.claude` logs, browser profiles, OEM `C:\Recovery`, shadow copies, pagefile | — | Ask, or leave |

Also check the Windows Error Reporting log and System events (`nvlddmkm` 153, `LiveKernelEvent`) to find what produced the dumps.
