$ErrorActionPreference = "Stop"

try {
    Write-Host "azure-status-proxy start" -ForegroundColor Green

    Write-Host "Getting chezmoi source path..." -ForegroundColor Cyan
    $sourceDir = $env:CHEZMOI_SOURCE_DIR

    if ([string]::IsNullOrWhiteSpace($sourceDir)) {
        throw "CHEZMOI_SOURCE_DIR environment variable is not set. Is this script running from chezmoi?"
    }

    Write-Host "Source path: $sourceDir" -ForegroundColor Yellow

    $targetDir = Join-Path (Split-Path $sourceDir -Parent) "azure-status-proxy"

    if (-not (Test-Path $targetDir)) {
        throw "Directory '$targetDir' does not exist"
    }

    Write-Host "Changing to directory: $targetDir" -ForegroundColor Cyan
    Set-Location $targetDir

    Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow

    if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
        throw "Go is not installed or not available in PATH"
    }

    if (-not (Test-Path "go.mod")) {
        Write-Warning "go.mod file not found. Is this a Go project?"
    }

    Write-Host "Starting Go project build..." -ForegroundColor Cyan
    go build -v -ldflags "-H windowsgui" .

    if ($LASTEXITCODE -ne 0) {
        throw "Build failed with exit code: $LASTEXITCODE"
    }

    Write-Host "`nBuild completed successfully!" -ForegroundColor Green

}
catch {
    Write-Host "`nAn error occurred:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nStack trace:" -ForegroundColor Yellow
    Write-Host $_.ScriptStackTrace -ForegroundColor Yellow
    exit 1
}
finally {
    $ErrorActionPreference = "Continue"
}
