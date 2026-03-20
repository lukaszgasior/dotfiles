# Copy PowerShell profile to the correct location when $PROFILE points
# to a non-standard path (e.g. OneDrive-synced Documents on corporate machines).

$ErrorActionPreference = 'Stop'

try {
    $standardPath = Join-Path $env:USERPROFILE 'Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
    $actualProfile = pwsh -NoProfile -Command '$PROFILE.CurrentUserCurrentHost'

    if ([string]::IsNullOrWhiteSpace($actualProfile)) {
        Write-Host 'Could not determine $PROFILE path, skipping.' -ForegroundColor Yellow
        exit 0
    }

    $standardNorm = [System.IO.Path]::GetFullPath($standardPath)
    $actualNorm = [System.IO.Path]::GetFullPath($actualProfile)

    if ($standardNorm -eq $actualNorm) {
        Write-Host 'PowerShell profile is in standard location, no copy needed.' -ForegroundColor Green
        exit 0
    }

    if (-not (Test-Path $standardPath)) {
        Write-Host "Source profile not found at $standardPath, skipping." -ForegroundColor Yellow
        exit 0
    }

    $targetDir = Split-Path $actualProfile -Parent
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        Write-Host "Created directory: $targetDir" -ForegroundColor Cyan
    }

    Copy-Item -Path $standardPath -Destination $actualProfile -Force
    Write-Host "Copied PowerShell profile to: $actualProfile" -ForegroundColor Green

} catch {
    Write-Host "Error copying PowerShell profile: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
