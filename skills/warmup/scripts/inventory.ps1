<#
Read-only dev machine inventory for the warmup skill. Changes nothing.
  pwsh -File inventory.ps1 [-Quick]
#>
param([switch]$Quick)
$ErrorActionPreference = 'SilentlyContinue'
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')

"=== Disk ==="
Get-PSDrive -PSProvider FileSystem | Where-Object Used | ForEach-Object { "{0}: {1:N1} GB free of {2:N1} GB{3}" -f $_.Name, ($_.Free/1GB), (($_.Used+$_.Free)/1GB), $(if ($_.Free -lt 30GB) { '   <-- LOW: recover space before installing' }) }

"`n=== Running work (stage changes, swap only when idle) ==="
Get-Process claude, codex, gemini, agy, go, gopls, node, java, gradle, dart, flutter, docker, 'Docker Desktop' |
  Group-Object Name | ForEach-Object { "{0,-16} x{1}" -f $_.Name, $_.Count }
$dk = docker ps --format '{{.Names}}' 2>$null; if ($dk) { "docker containers running: $(@($dk).Count)" }

"`n=== Package managers ==="
foreach ($c in 'scoop','winget','choco') { "{0,-8} {1}" -f $c, $(if (Get-Command $c) { 'present' } else { '-' }) }
if (Test-Path 'C:\DevTools\scoop') { "Scoop root: C:\DevTools\scoop" }

"`n=== Tools (name / resolved path / duplicates) ==="
$tools = 'go','gopls','dlv','golangci-lint','node','npm','pnpm','fnm','bun','deno','git','gh','python','py','uv','ruby','gem','java','kotlinc','gradle','flutter','adb','android','docker','psql','code','make','jq','rg','fd','fzf','protoc','buf','gcloud','aws','az','kubectl','helm','cloudflared','wrangler','eas'
foreach ($t in $tools) {
  $all = @(Get-Command $t -All -CommandType Application, ExternalScript)
  if (-not $all) { "{0,-14} MISSING" -f $t; continue }
  # npm.ps1/npm.cmd/npm in one folder is one install; flag only when the tool exists in different folders
  $dirs = @($all | ForEach-Object { Split-Path $_.Source } | Select-Object -Unique)
  $dup = if ($dirs.Count -gt 1) { "  (ALSO IN: " + (($dirs | Select-Object -Skip 1) -join '; ') + ')' } else { '' }
  "{0,-14} {1}{2}" -f $t, $all[0].Source, $dup
}

if (-not $Quick) {
  "`n=== Versions of core toolchains ==="
  foreach ($v in @(@('go','version'),@('node','--version'),@('pnpm','--version'),@('git','--version'),@('python','--version'),@('java','-version'),@('ruby','--version'),@('flutter','--version'))) {
    if (Get-Command $v[0]) { $j = Start-Job { param($c,$a) & $c $a 2>&1 | Select-Object -First 1 } -ArgumentList $v[0], $v[1]
      $o = if (Wait-Job $j -Timeout 30) { Receive-Job $j } else { 'timeout' }; Remove-Job $j -Force; "{0,-8} {1}" -f $v[0], "$o".Trim() }
  }
  "`n=== Env ==="
  foreach ($n in 'GOPATH','GOBIN','GOROOT','JAVA_HOME','ANDROID_HOME','ANDROID_NDK_HOME','FNM_DIR','PNPM_HOME','GEM_HOME','MSYS2_PATH','UV_TOOL_DIR','WEBVIEW2_BROWSER_EXECUTABLE_FOLDER') {
    $u = [Environment]::GetEnvironmentVariable($n,'User'); $m = [Environment]::GetEnvironmentVariable($n,'Machine')
    if ($u -or $m) { "{0,-36} {1}" -f $n, ($(if ($u) { "user=$u " }) + $(if ($m) { "machine=$m" })) }
  }
}

"`n=== PATH problems ==="
foreach ($sc in 'Machine','User') {
  $seen = @{}
  foreach ($p in ([Environment]::GetEnvironmentVariable('Path',$sc) -split ';' | Where-Object { $_ })) {
    $k = $p.TrimEnd([char]92).ToLower()
    if (-not (Test-Path ([Environment]::ExpandEnvironmentVariables($p)))) { "$sc DEAD: $p" }
    elseif ($seen[$k]) { "$sc DUPLICATE: $p" }
    $seen[$k] = 1
  }
}
"`n=== Store aliases that hijack commands ==="
Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WindowsApps" -Filter 'python*.exe' | ForEach-Object { "alias present: $($_.Name)" }
