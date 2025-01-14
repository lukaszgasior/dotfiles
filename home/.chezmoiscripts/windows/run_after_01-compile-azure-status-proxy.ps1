Write-Host "Start"
$sourceDir = chezmoi source-path
Write-Host "Current directory: $sourceDir"
cd $sourceDir/../azure-status-proxy
Write-Host "Build directory: $(Get-Location)"
go build -v -ldflags "-H windowsgui" .
