[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$chezmoiSourceDir = chezmoi source-path | Out-String
$chezmoiSourceDir = $chezmoiSourceDir.Trim()
$wingetExportPath = Join-Path $chezmoiSourceDir ".chezmoidata\winget-export.json"

if (-not (Test-Path $wingetExportPath)) {
    Write-Error "Winget export file not found at: $wingetExportPath"
    exit 1
}

winget import -i $wingetExportPath --accept-source-agreements --accept-package-agreements
