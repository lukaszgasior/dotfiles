if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        Write-Host "Requesting administrator privileges..."
        $CommandLine = "-NoExit -File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -Wait -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

$toolsPath = Join-Path $env:USERPROFILE ".tools\Win11Debloat"
$debloatScript = Join-Path $toolsPath "Win11Debloat.ps1"

if (-not (Test-Path $toolsPath)) {
    Write-Error "Directory $toolsPath does not exist!"
    exit 1
}

if (-not (Test-Path $debloatScript)) {
    Write-Error "Win11Debloat.ps1 script not found in $toolsPath!"
    exit 1
}

try {
    & $debloatScript `
        -DisableBing `
        -DisableTelemetry `
        -DisableSuggestions `
        -DisableLockscreenTips `
        -RevertContextMenu `
        -ShowHiddenFolders `
        -ShowKnownFileExt `
        -HideSearchTb `
        -HideTaskview `
        -HideChat `
        -DisableWidgets `
        -DisableCopilot `
        -DisableRecall `
        -RemoveW11Outlook `
        -DisableStartRecommended `
        -DisableStartPhoneLink `
        -DisableDesktopSpotlight `
        -DisableMouseAcceleration `
        -DisableStickyKeys `
        -EnableDarkMode `
        -DisableTransparency `
        -Silent
}
catch {
    Write-Error "Error occurred while running the script: $_"
    exit 1
}
