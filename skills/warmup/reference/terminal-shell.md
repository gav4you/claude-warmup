# Terminal & shell foundation (do this first)

Claude Code runs in the console, so fix the console before installing anything else. In the old console host (conhost), paste often fails and there are no tabs. Windows PowerShell 5.1 is frozen; current tools and scripts assume PowerShell 7.

## 1. Windows Terminal: install/upgrade, then make it the default
- **Install or upgrade:** `winget install --id Microsoft.WindowsTerminal -e` (MSIX).
- **If winget fails with 0x80070422:** Delivery Optimization (DoSvc) is disabled. Download `Microsoft.WindowsTerminal_<ver>_8wekyb3d8bbwe.msixbundle` from github.com/microsoft/terminal/releases, check it against the release's SHA-256, and run `Add-AppxPackage <file>`. If it asks for dependencies, install them from that release's `PreinstallKit` zip.
- **Make it the default terminal**, so every console window, including ones Claude Code opens, uses it.
  - **Settings app:** System → For developers → Terminal → *Windows Terminal*.
  - **Scripted:** back up first (`reg export "HKCU\Console\%%Startup" <file>.reg`), then:
    ```powershell
    New-Item 'HKCU:\Console\%%Startup' -Force | Out-Null
    Set-ItemProperty 'HKCU:\Console\%%Startup' DelegationConsole  '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}'
    Set-ItemProperty 'HKCU:\Console\%%Startup' DelegationTerminal '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}'
    ```
    (conhost = `{B23D10C0-E52E-411E-9D5B-C09FDF709C7D}` for both; "let Windows decide" = all zeros.) Windows already open stay on their old host.

## 2. PowerShell 7
| Copy | Source | Why |
|---|---|---|
| **LTS** (e.g. 7.6.x), the system pwsh | `PowerShell-<ver>-win-x64.msi` from github.com/PowerShell/PowerShell/releases (check against the release's `hashes.sha256`); `msiexec /i <msi> /qn ADD_PATH=1` | Stable path `C:\Program Files\PowerShell\7\pwsh.exe` that scheduled tasks, services and scripts can hardcode. Supported 3 years |
| **Current** (e.g. 7.7), optional | `winget install --id Microsoft.PowerShell -e` (now MSIX), or the GitHub `.msixbundle` + `Add-AppxPackage` when DoSvc is off | Newest features. Per-user, installs side by side with the LTS. Its `pwsh` alias is in `%LOCALAPPDATA%\Microsoft\WindowsApps` |

- **Upgrading the LTS MSI:** first stop the scheduled tasks and services that run pwsh, and close pwsh windows, or the installer schedules a reboot. Never remove the copy that tasks point at. Find them with `Get-ScheduledTask | % { $_.Actions.Execute } | sls pwsh`.
- **Keep Windows PowerShell 5.1.** It's a Windows component and can't be removed, but you can hide its profile in Terminal.
- **Execution policy:** `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

## 3. Terminal settings (`%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json`)
- `defaultProfile` = the pwsh 7 profile's GUID. Give it a clear name, e.g. "PowerShell 7.6 LTS" / "PowerShell 7.7".
- Optional `"elevate": true` on the profile used for machine-setup work. Admin is needed for MSI, services and HKLM.
- Hide the Windows PowerShell 5.1 profile (`"hidden": true`) so nobody opens it by accident.
- Back up settings.json before editing; Terminal reloads it live.

## 4. Profile
- `$PROFILE` lives under the **Documents** folder. If Documents is redirected to OneDrive, or moved back, the profile path moves too. Re-check `$PROFILE` after any Documents change, and keep one profile file.
- Keep it small and fast:
  - `fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression` (per-project Node)
  - optionally `Set-PSReadLineOption -PredictionSource History`
- No heavy modules: Claude Code launches many shells.

## Delivery Optimization off: what still works
With DoSvc disabled, only **MSIX/Store** packages fail (0x80070422): Windows Terminal, PowerShell current, App Installer. winget's **MSI/EXE** installs still download and install normally; Node, PostgreSQL, Docker and cloudflared were all verified this way. Use the GitHub `.msixbundle` + `Add-AppxPackage` just for the MSIX ones.

## Managed (company) laptops
Check first:
- `Get-ExecutionPolicy -List`. A MachinePolicy/UserPolicy scope overrides `Set-ExecutionPolicy`; use `powershell -ExecutionPolicy Bypass -File …` per run, or ask IT.
- Admin rights: `([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrators')`.
- Whether AppX sideloading is allowed.

**Without admin:**
- Scoop still works (it installs per user, no admin), so put everything possible there.
- PowerShell 7: use the per-user MSIX, or the GitHub `PowerShell-<ver>-win-x64.zip` unpacked under `C:\DevTools\sdk\pwsh`.
- Terminal's default-terminal setting is per-user (HKCU), so it still works.
- Leave services (Docker, a Postgres server) and MSI installs to IT. Don't try to work around policy.

## After switching the default terminal
The window you're in stays on the old host. Tell the user to **close and relaunch Claude Code from Windows Terminal** before continuing.

## Verify
- `(Get-Command pwsh).Source`
- `pwsh -NoProfile -c '$PSVersionTable.PSVersion'` for each copy
- `Get-ItemProperty 'HKCU:\Console\%%Startup'`
- Open a new window from Win+R → `cmd`. It should open inside Windows Terminal.
