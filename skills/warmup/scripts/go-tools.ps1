$ErrorActionPreference = 'Continue'
$go = (Get-Command go -ErrorAction Stop).Source   # whichever go is first on PATH
$env:GOTOOLCHAIN = 'local'
$tools = @(
  @('golang.org/x/tools/gopls@latest', ''),
  @('github.com/go-delve/delve/cmd/dlv@latest', ''),
  @('honnef.co/go/tools/cmd/staticcheck@latest', ''),
  @('mvdan.cc/gofumpt@latest', ''),
  @('github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest', ''),
  @('gotest.tools/gotestsum@latest', ''),
  @('golang.org/x/vuln/cmd/govulncheck@latest', ''),
  @('github.com/air-verse/air@latest', ''),
  @('go.uber.org/mock/mockgen@latest', ''),
  @('github.com/golang-migrate/migrate/v4/cmd/migrate@latest', 'postgres pgx5 sqlite file github'),
  @('google.golang.org/protobuf/cmd/protoc-gen-go@latest', ''),
  @('google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest', ''),
  @('connectrpc.com/connect/cmd/protoc-gen-connect-go@latest', ''),
  @('github.com/fullstorydev/grpcurl/cmd/grpcurl@latest', ''),
  @('github.com/swaggo/swag/cmd/swag@latest', ''),
  @('github.com/goreleaser/goreleaser/v2@latest', ''),
  @('github.com/riverqueue/river/cmd/river@latest', ''),
  @('github.com/wailsapp/wails/v2/cmd/wails@latest', ''),
  @('github.com/a-h/templ/cmd/templ@latest', ''),
  @('github.com/sqlc-dev/sqlc/cmd/sqlc@latest', ''),
  @('github.com/securego/gosec/v2/cmd/gosec@latest', ''),
  @('github.com/fatih/gomodifytags@latest', ''),
  @('github.com/josharian/impl@latest', ''),
  @('github.com/cweill/gotests/gotests@latest', ''),
  @('github.com/haya14busa/goplay/cmd/goplay@latest', ''),
  @('github.com/google/osv-scanner/v2/cmd/osv-scanner@latest', ''),
  @('github.com/google/go-licenses/v2@latest', ''),
  @('github.com/pressly/goose/v3/cmd/goose@latest', ''),
  @('github.com/CycloneDX/cyclonedx-gomod/cmd/cyclonedx-gomod@latest', '')
)
foreach ($t in $tools) {
  $a = @('install')
  if ($t[1]) { $a += @('-tags', $t[1]) }
  $a += $t[0]
  $out = & $go @a 2>&1 | Out-String
  "{0,-70} {1}" -f $t[0], $(if ($LASTEXITCODE -eq 0) { 'OK' } else { 'FAIL: ' + ($out.Trim() -split "`n" | Select-Object -Last 2) -join ' / ' })
}
'GO TOOLS DONE'


