$ErrorActionPreference = 'Continue'
$go = (Get-Command go -ErrorAction Stop).Source   # whichever go is first on PATH
$env:GOTOOLCHAIN = 'local'
$t = 'golang.org/x/tools'
$pkgs = @(
 "$t/cmd/bisect","$t/cmd/bundle","$t/cmd/callgraph","$t/cmd/deadcode","$t/cmd/digraph","$t/cmd/eg","$t/cmd/file2fuzz",
 "$t/cmd/fiximports","$t/cmd/godex","$t/cmd/goimports","$t/cmd/gomvpkg","$t/cmd/gonew","$t/cmd/gotype","$t/cmd/goyacc",
 "$t/cmd/present","$t/cmd/present2md","$t/cmd/ssadump","$t/cmd/stress","$t/cmd/stringer","$t/go/packages/gopackages",
 "$t/go/analysis/passes/defers/cmd/defers","$t/go/analysis/passes/fieldalignment/cmd/fieldalignment",
 "$t/go/analysis/passes/httpmux/cmd/httpmux","$t/go/analysis/passes/ifaceassert/cmd/ifaceassert",
 "$t/go/analysis/passes/inline/cmd/inline","$t/go/analysis/passes/lostcancel/cmd/lostcancel",
 "$t/go/analysis/passes/modernize/cmd/modernize","$t/go/analysis/passes/nilness/cmd/nilness",
 "$t/go/analysis/passes/reflectvaluecompare/cmd/reflectvaluecompare","$t/go/analysis/passes/shadow/cmd/shadow",
 "$t/go/analysis/passes/stringintconv/cmd/stringintconv","$t/go/analysis/passes/unmarshal/cmd/unmarshal",
 "$t/go/analysis/passes/unusedresult/cmd/unusedresult",
 'golang.org/x/exp/cmd/apidiff','golang.org/x/exp/cmd/gorelease','golang.org/x/exp/cmd/modgraphviz','golang.org/x/exp/cmd/txtar',
 'golang.org/x/mobile/cmd/gomobile','golang.org/x/mobile/cmd/gobind',
 'golang.org/x/mod/gosumcheck','golang.org/x/net/http2/h2i',
 'golang.org/x/perf/cmd/benchstat','golang.org/x/perf/cmd/benchfilter','golang.org/x/perf/cmd/benchseries','golang.org/x/perf/cmd/benchsave',
 'golang.org/x/pkgsite/cmd/pkgsite','golang.org/x/review/git-codereview','golang.org/x/telemetry/cmd/gotelemetry',
 'golang.org/x/text/cmd/gotext','golang.org/x/debug/cmd/viewcore','golang.org/x/sys/windows/mkwinsyscall','golang.org/x/website/tour'
)
foreach ($p in $pkgs) {
  $out = & $go install "$p@latest" 2>&1 | Out-String
  "{0,-72} {1}" -f $p, $(if ($LASTEXITCODE -eq 0) { 'OK' } else { 'FAIL: ' + (($out.Trim() -split "`n") | Select-Object -Last 1) })
}
'X DONE'


