param([string[]]$Paths, [switch]$Children)
# Fast directory sizing via robocopy list mode (no copying). Skips junctions (/XJ).
function Get-DirBytes([string]$p) {
    if (-not (Test-Path -LiteralPath $p)) { return $null }
    $item = Get-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue
    if ($item -and -not $item.PSIsContainer) { return $item.Length }
    $out = robocopy $p "C:\__nonexistent_dest__" /L /S /NJH /NFL /NDL /BYTES /XJ /R:0 /W:0 /NP 2>$null
    $line = $out | Where-Object { $_ -match '^\s*Bytes\s*:' } | Select-Object -First 1
    if ($line -match 'Bytes\s*:\s*(\d+)') { return [int64]$Matches[1] }
    return $null
}
$targets = @()
foreach ($p in $Paths) {
    if ($Children) {
        if (Test-Path -LiteralPath $p) {
            $targets += Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue |
                Where-Object { -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) } |
                ForEach-Object { $_.FullName }
        }
    } else { $targets += $p }
}
$rows = foreach ($t in $targets) {
    $b = Get-DirBytes $t
    if ($null -ne $b) { [pscustomobject]@{ GB = [math]::Round($b / 1GB, 2); Path = $t } }
}
$rows | Sort-Object GB -Descending | Format-Table -AutoSize | Out-String -Width 300
