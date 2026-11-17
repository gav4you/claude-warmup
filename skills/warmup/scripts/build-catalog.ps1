<#
Rebuilds C:\DevTools category folders (shortcuts), catalog.json and README.md.
Re-run any time after installing/updating tools:  pwsh -File C:\DevTools\_scripts\build-catalog.ps1
#>
$ErrorActionPreference = 'Continue'
$root = 'C:\DevTools'
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')

# name | category | kind(cli/gui) | purpose | version-args | explicit path (gui/non-PATH)
$tools = @(
 # Go
 @('go','01-Go','cli','Go toolchain (compiler, test, mod)','version'),
 @('gopls','01-Go','cli','Go language server (editors/agents)','version'),
 @('dlv','01-Go','cli','Delve debugger','version'),
 @('golangci-lint','01-Go','cli','Meta-linter (uses .golangci.yml)','version'),
 @('staticcheck','01-Go','cli','Static analysis','-version'),
 @('gofumpt','01-Go','cli','Strict gofmt','--version'),
 @('goimports','01-Go','cli','Format + fix imports',''),
 @('gotestsum','01-Go','cli','Readable go test runner','--version'),
 @('air','01-Go','cli','Live reload for Go web servers','-v'),
 @('mockgen','01-Go','cli','go.uber.org/mock generator','--version'),
 @('wails','01-Go','cli','Go desktop apps (web UI + Go backend)','version'),
 @('templ','01-Go','cli','templ HTML templating codegen','version'),
 @('sqlc','01-Go','cli','SQL -> type-safe Go codegen','version'),
 @('goreleaser','01-Go','cli','Release/packaging automation','--version'),
 @('river','01-Go','cli','River job-queue migrations CLI','version'),
 @('swag','01-Go','cli','Swagger docs from Go comments','--version'),
 @('gomobile','01-Go','cli','Go -> Android/iOS libraries (NDK ready)',''),
 @('deadcode','01-Go','cli','Find unreachable functions (golang.org/x)',''),
 @('benchstat','01-Go','cli','Compare benchmark results (golang.org/x)',''),
 @('stringer','01-Go','cli','Generate String() for enums (golang.org/x)',''),
 @('gonew','01-Go','cli','Start module from template (golang.org/x)',''),
 @('modernize','01-Go','cli','Modernize Go idioms analyzer (golang.org/x)',''),
 @('pkgsite','01-Go','cli','Local Go docs server (golang.org/x)',''),
 @('tour','01-Go','cli','Offline Go Tour (golang.org/x)',''),
 # JS
 @('node','02-JavaScript','cli','Node.js (system LTS)','--version'),
 @('npm','02-JavaScript','cli','npm','--version'),
 @('pnpm','02-JavaScript','cli','pnpm package manager','--version'),
 @('yarn','02-JavaScript','cli','Yarn classic','--version'),
 @('bun','02-JavaScript','cli','Bun runtime/bundler','--version'),
 @('deno','02-JavaScript','cli','Deno runtime','--version'),
 @('fnm','02-JavaScript','cli','Per-project Node versions (.nvmrc)','--version'),
 @('tsc','02-JavaScript','cli','TypeScript compiler','--version'),
 @('tailwindcss','02-JavaScript','cli','Tailwind CSS standalone CLI','--help'),
 @('eas','03-Mobile-Desktop','cli','Expo Application Services (builds/submit)','--version'),
 # Mobile / desktop
 @('flutter','03-Mobile-Desktop','cli','Flutter SDK','--version'),
 @('dart','03-Mobile-Desktop','cli','Dart SDK','--version'),
 @('adb','03-Mobile-Desktop','cli','Android Debug Bridge','version'),
 @('emulator','03-Mobile-Desktop','cli','Android emulator','-version'),
 @('android','03-Mobile-Desktop','cli','Android CLI (replaces sdkmanager): android sdk install ...','--version'),
 @('java','03-Mobile-Desktop','cli','JDK 21 (JAVA_HOME)','-version'),
 @('kotlinc','03-Mobile-Desktop','cli','Kotlin compiler','-version'),
 @('gradle','03-Mobile-Desktop','cli','Gradle build tool','--version'),
 @('fastlane','03-Mobile-Desktop','cli','iOS/Android release automation (Ruby gem on Scoop ruby33)',''),
 @('Android Studio','03-Mobile-Desktop','gui','Android IDE','', 'C:\Program Files\Android\Android Studio\bin\studio64.exe'),
 # Databases
 @('psql','04-Databases','cli','PostgreSQL client','--version'),
 @('pgcli','04-Databases','cli','psql with autocomplete','--version'),
 @('sqlite3','04-Databases','cli','SQLite shell','--version'),
 @('migrate','04-Databases','cli','golang-migrate (postgres/pgx5/sqlite)','-version'),
 @('goose','04-Databases','cli','pressly/goose migrations','--version'),
 @('pgAdmin 4','04-Databases','gui','PostgreSQL admin GUI','', 'C:\Program Files\PostgreSQL\18\pgAdmin 4\runtime\pgAdmin4.exe'),
 @('DBeaver','04-Databases','gui','Universal DB GUI','', 'C:\DevTools\scoop\apps\dbeaver\current\dbeaver.exe'),
 @('Beekeeper Studio','04-Databases','gui','SQL editor GUI','', 'C:\DevTools\scoop\apps\beekeeper-studio\current\Beekeeper Studio.exe'),
 # Containers / cloud
 @('docker','05-Containers-Cloud','cli','Docker CLI (Docker Desktop)','--version'),
 @('kubectl','05-Containers-Cloud','cli','Kubernetes CLI','version --client'),
 @('helm','05-Containers-Cloud','cli','Kubernetes package manager','version --short'),
 @('gh','05-Containers-Cloud','cli','GitHub CLI','--version'),
 @('wrangler','05-Containers-Cloud','cli','Cloudflare Workers CLI','--version'),
 @('cloudflared','05-Containers-Cloud','cli','Cloudflare tunnel','--version'),
 @('gcloud','05-Containers-Cloud','cli','Google Cloud CLI','--version'),
 @('aws','05-Containers-Cloud','cli','AWS CLI','--version'),
 @('az','05-Containers-Cloud','cli','Azure CLI',''),
 @('stripe','05-Containers-Cloud','cli','Stripe CLI','--version'),
 @('Docker Desktop','05-Containers-Cloud','gui','Docker Desktop app','', 'C:\Program Files\Docker\Docker\Docker Desktop.exe'),
 # API / codegen
 @('protoc','06-API-Protobuf-HTTP','cli','Protocol Buffers compiler','--version'),
 @('buf','06-API-Protobuf-HTTP','cli','Protobuf lint/breaking/generate','--version'),
 @('protoc-gen-go','06-API-Protobuf-HTTP','cli','protoc Go plugin','--version'),
 @('protoc-gen-go-grpc','06-API-Protobuf-HTTP','cli','protoc gRPC plugin','--version'),
 @('protoc-gen-connect-go','06-API-Protobuf-HTTP','cli','protoc Connect plugin','--version'),
 @('grpcurl','06-API-Protobuf-HTTP','cli','curl for gRPC','--version'),
 @('xh','06-API-Protobuf-HTTP','cli','Fast HTTP client','--version'),
 @('http','06-API-Protobuf-HTTP','cli','HTTPie','--version'),
 @('k6','06-API-Protobuf-HTTP','cli','Load testing','version'),
 @('mkcert','06-API-Protobuf-HTTP','cli','Local trusted HTTPS certs','-version'),
 @('Bruno','06-API-Protobuf-HTTP','gui','API client (git-friendly)','', 'C:\DevTools\scoop\apps\bruno\current\Bruno.exe'),
 # CLI utilities
 @('git','07-CLI-Utilities','cli','Git for Windows (system install)','--version'),
 @('lazygit','07-CLI-Utilities','cli','Git TUI','--version'),
 @('delta','07-CLI-Utilities','cli','Better git diffs','--version'),
 @('jq','07-CLI-Utilities','cli','JSON processor','--version'),
 @('yq','07-CLI-Utilities','cli','YAML/TOML/XML processor','--version'),
 @('rg','07-CLI-Utilities','cli','ripgrep search','--version'),
 @('fd','07-CLI-Utilities','cli','Fast file finder','--version'),
 @('fzf','07-CLI-Utilities','cli','Fuzzy finder','--version'),
 @('bat','07-CLI-Utilities','cli','cat with syntax highlighting','--version'),
 @('make','07-CLI-Utilities','cli','GNU make','--version'),
 @('just','07-CLI-Utilities','cli','Command runner (justfile)','--version'),
 @('task','07-CLI-Utilities','cli','go-task (Taskfile.yml)','--version'),
 @('7z','07-CLI-Utilities','cli','7-Zip','i'),
 @('gdu','07-CLI-Utilities','cli','Disk usage analyzer','--version'),
 @('es','07-CLI-Utilities','cli','Everything search CLI (instant file search, folder sizes)','-version'),
 @('dot','07-CLI-Utilities','cli','Graphviz (pprof graphs)','-V'),
 @('upx','07-CLI-Utilities','cli','Executable packer','--version'),
 @('makensis','07-CLI-Utilities','cli','NSIS installer builder','-VERSION'),
 @('gcc','07-CLI-Utilities','cli','MinGW-w64 gcc (cgo)','--version'),
 @('Everything','07-CLI-Utilities','gui','Everything search GUI','', 'C:\DevTools\scoop\apps\everything\current\everything.exe'),
 # Security
 @('govulncheck','08-Security','cli','Go vulnerability check (golang.org/x)','-version'),
 @('gosec','08-Security','cli','Go security linter','-version'),
 @('trivy','08-Security','cli','Container/IaC/dependency scanner','--version'),
 @('osv-scanner','08-Security','cli','OSV dependency scanner','--version'),
 @('hadolint','08-Security','cli','Dockerfile linter','--version'),
 @('go-licenses','08-Security','cli','Dependency license report',''),
 @('cyclonedx-gomod','08-Security','cli','SBOM generator','version'),
 # Python
 @('python','09-Python-Ruby','cli','Python 3.14 (Scoop python314; py launcher registered)','--version'),
 @('pip','09-Python-Ruby','cli','pip for the global Python','--version'),
 @('uv','09-Python-Ruby','cli','Python package/project/tool manager','--version'),
 @('ruff','09-Python-Ruby','cli','Python linter/formatter','--version'),
 @('ruby','09-Python-Ruby','cli','Ruby 3.3 (Scoop ruby33; gems persist in scoop\persist\ruby33\gems)','--version'),
 @('gem','09-Python-Ruby','cli','RubyGems','--version'),
 @('bundle','09-Python-Ruby','cli','Bundler','--version'),
 @('ridk','09-Python-Ruby','cli','RubyInstaller devkit (uses MSYS2_PATH -> Scoop msys2)','version'),
 @('msys2','09-Python-Ruby','cli','MSYS2 shell + gcc toolchain for native gems',''),
 @('gitlab-runner','05-Containers-Cloud','cli','GitLab CI runner','--version'),
 @('TotalRegistry','07-CLI-Utilities','gui','Registry viewer (portable)','', 'C:\DevTools\portable\TotalRegistry\TotalReg.exe'),
 # Editors
 @('code','10-Editors-IDEs','cli','VS Code CLI','--version'),
 @('VS Code','10-Editors-IDEs','gui','Visual Studio Code','', "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"),
 @('Notepad++','10-Editors-IDEs','gui','Notepad++','', 'C:\Program Files\Notepad++\notepad++.exe'),
 @('GitHub Desktop','10-Editors-IDEs','gui','GitHub Desktop','', "$env:LOCALAPPDATA\GitHubDesktop\GitHubDesktop.exe")
)

function Get-Source([string]$p) {
  if ($p -like 'C:\DevTools\scoop\*') { 'scoop' } elseif ($p -like 'C:\DevTools\gopath\*') { 'go install' }
  elseif ($p -like 'C:\DevTools\sdk\*') { 'portable sdk' } elseif ($p -like 'C:\DevTools\portable\*') { 'portable app' } elseif ($p -like '*AppData\Roaming\npm*') { 'npm -g' }
  elseif ($p -like '*Android\Sdk*') { 'android sdk' } else { 'system install' }
}
function Resolve-Real([string]$p) {
  # scoop shims -> real exe
  if ($p -like 'C:\DevTools\scoop\shims\*') { $shim = [IO.Path]::ChangeExtension($p, '.shim'); if (Test-Path $shim) { $l = Get-Content $shim | Where-Object { $_ -like 'path*' } | Select-Object -First 1; if ($l -match '"(.+)"') { return $Matches[1] } } }
  $p
}

$sh = New-Object -ComObject WScript.Shell
$cats = $tools | ForEach-Object { $_[1] } | Select-Object -Unique
foreach ($c in $cats) { $d = Join-Path $root $c; if (Test-Path $d) { Get-ChildItem $d -Filter *.lnk | Remove-Item -Force } else { New-Item -ItemType Directory $d | Out-Null } }

$catalog = foreach ($t in $tools) {
  $name, $cat, $kind, $purpose, $vargs = $t[0..4]; $explicit = if ($t.Count -gt 5) { $t[5] } else { $null }
  $cmdPath = if ($explicit) { $explicit } else { (Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1).Source }
  $exists = $cmdPath -and (Test-Path $cmdPath)
  $real = if ($exists) { Resolve-Real $cmdPath } else { $null }
  $ver = ''
  if ($exists -and $kind -eq 'cli' -and $vargs) {
    try { $j = Start-Job { param($c,$a) & $c @($a -split ' ') 2>&1 | Out-String } -ArgumentList $cmdPath, $vargs
          if (Wait-Job $j -Timeout 20) { $ver = ((Receive-Job $j) -split "`n" | Where-Object { $_ -match '\d+\.\d+' } | Select-Object -First 1).Trim() }
          Remove-Job $j -Force } catch {}
  }
  if ($exists) {
    $lnk = $sh.CreateShortcut((Join-Path (Join-Path $root $cat) "$name.lnk"))
    if ($kind -eq 'gui') { $lnk.TargetPath = $real; $lnk.WorkingDirectory = Split-Path $real }
    else { $lnk.TargetPath = 'C:\Program Files\PowerShell\7\pwsh.exe'; $lnk.Arguments = "-NoExit -Command `"Write-Host '$name - $purpose' -f Cyan; & '$cmdPath' $(if ($vargs) { $vargs } else { '--help' })`""; $lnk.WorkingDirectory = $env:USERPROFILE; $lnk.IconLocation = "$real,0" }
    $lnk.Description = $purpose; $lnk.Save()
  }
  [pscustomobject]@{ name=$name; category=$cat; kind=$kind; purpose=$purpose; command=$(if ($kind -eq 'cli') { $name } else { $null }); path=$real; source=$(if ($real) { Get-Source $real } else { $null }); version=$ver; present=[bool]$exists }
}

$catalog | ConvertTo-Json -Depth 3 | Set-Content (Join-Path $root 'catalog.json') -Encoding UTF8

$md = @("# C:\DevTools", "", "Central index of this machine's dev toolchain. Generated $(Get-Date -Format 'yyyy-MM-dd HH:mm') by ``_scripts\build-catalog.ps1`` (re-run after installs/updates).", "",
 "## Layout", "| Path | What |", "|---|---|",
 "| ``scoop\`` | Scoop root: every portable app in ``scoop\apps\<name>\current``, shims on PATH in ``scoop\shims`` |",
 "| ``gopath\`` | GOPATH: ``bin\`` = all go-installed tools (GOBIN), ``pkg\mod`` = module cache. ``%USERPROFILE%\go`` is a junction here |",
 "| ``gocache\`` | GOCACHE (build cache; safe to clear with ``go clean -cache``) |",
 "| ``sdk\flutter\`` | Flutter SDK (``%USERPROFILE%\flutter`` junction points here) |",
 "| ``fnm\`` | FNM_DIR: Node 24/26 for per-project switching |",
 "| ``NN-Category\`` | Shortcuts: GUI apps open directly; CLI shortcuts open PowerShell showing the tool |",
 "| ``portable\`` | Portable non-Scoop apps: TotalRegistry, WhatsAppDesktop-Offline (fixed WebView2 runtime; WEBVIEW2_BROWSER_EXECUTABLE_FOLDER points here) |",
 "| ``_installers\`` | Verified offline installers kept for reinstall |",
 "| ``_scripts\`` | Maintenance scripts (catalog, disk sizing, cleanup, Go tool reinstall) |",
 "| ``catalog.json`` | Machine-readable list: name, category, path, source, version |", "",
 "## Update everything", '```powershell', 'scoop update; scoop update *          # all Scoop apps', 'pwsh -File C:\DevTools\_scripts\go-tools.ps1   # rebuild Go tools @latest', 'npm i -g pnpm eas-cli wrangler            # npm globals', 'uv tool upgrade --all                     # httpie, pgcli', 'flutter upgrade', '```', "",
 "## Stays system-installed (needs Windows integration)", "Docker Desktop, PostgreSQL 18 (service), Git for Windows, Node.js LTS (C:\Program Files\nodejs), VS Code, Android Studio + SDK (``%LOCALAPPDATA%\Android\Sdk``), VS Build Tools, cloudflared (service), JDK 21, py launcher (C:\Windows\py.exe).", "")
foreach ($c in $cats) {
  $md += "## $c"; $md += '| Tool | Version | Source | Purpose |'; $md += '|---|---|---|---|'
  foreach ($r in ($catalog | Where-Object category -eq $c)) { $md += "| ``$($r.name)`` | $($r.version) | $($r.source) | $($r.purpose)$(if (-not $r.present) { ' **(missing)**' }) |" }
  $md += ''
}
$md | Set-Content (Join-Path $root 'README.md') -Encoding UTF8
"catalog: $(@($catalog).Count) tools, missing: " + (($catalog | Where-Object { -not $_.present }).name -join ', ')

