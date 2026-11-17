param([string[]]$Roots, [int]$Top = 25, [double]$MinGB = 0.5)
# Sizes each immediate child folder of each root using the Everything index (instant, MFT-based).
$es = "C:\DevTools\scoop\shims\es.exe"
foreach ($root in $Roots) {
    $root = $root.TrimEnd('\') + '\'
    $rows = foreach ($d in (Get-ChildItem -LiteralPath $root -Directory -Force -ErrorAction SilentlyContinue)) {
        if ($d.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
        $bytes = [double](& $es -get-total-size -path $d.FullName "file:")
        [pscustomobject]@{ GB = [math]::Round($bytes / 1GB, 2); Folder = $d.FullName }
    }
    $files = [double](& $es -get-total-size "file:" "parent:`"$($root.TrimEnd('\'))`"")
    "===== $root  (loose files directly in it: {0:N2} GB)" -f ($files / 1GB)
    $rows | Where-Object GB -ge $MinGB | Sort-Object GB -Descending | Select-Object -First $Top | Format-Table -AutoSize | Out-String -Width 300
}

