<#
.SYNOPSIS
    Adds VSCode to Windows context menu for files and directories.

.DESCRIPTION
    When VSCode is installed using winget, the context menu entries might not be added automatically to Windows.
    This script adds:
    - "Open with Code" option when right-clicking in folder background
    - "Open with Code" option when right-clicking on folder
    - "Edit with Code" option when right-clicking on files

    The script automatically elevates to admin rights if needed.
#>

if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        Write-Host "Requesting administrator privileges..."
        $CommandLine = "-NoExit -File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -Wait -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}


# Find VSCode executable path
$vscodePath = "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\Code.exe"
if (-not (Test-Path $vscodePath)) {
    Write-Error "VSCode not found at: $vscodePath"
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit
}

Write-Host "Found VSCode at: $vscodePath"

# Registry paths
$backgroundPath = "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\VSCode"
$backgroundCommandPath = "$backgroundPath\command"
$directoryPath = "Registry::HKEY_CLASSES_ROOT\Directory\shell\VSCode"
$directoryCommandPath = "$directoryPath\command"

# Add background context menu
Write-Host "`nAdding background context menu..."
if (-not (Test-Path $backgroundPath)) {
    New-Item -Path $backgroundPath -Force | Out-Null
    Set-ItemProperty -Path $backgroundPath -Name "(Default)" -Value "Open with Code"
    Set-ItemProperty -Path $backgroundPath -Name "Icon" -Value "`"$vscodePath`""
    New-Item -Path $backgroundCommandPath -Force | Out-Null
    Set-ItemProperty -Path $backgroundCommandPath -Name "(Default)" -Value "`"$vscodePath`" `"%V`""
    Write-Host "Added background context menu entry"
}
else {
    Write-Host "Background context menu entry already exists"
}

# Add directory context menu
Write-Host "`nAdding directory context menu..."
if (-not (Test-Path $directoryPath)) {
    New-Item -Path $directoryPath -Force | Out-Null
    Set-ItemProperty -Path $directoryPath -Name "(Default)" -Value "Open with Code"
    Set-ItemProperty -Path $directoryPath -Name "Icon" -Value "`"$vscodePath`""
    New-Item -Path $directoryCommandPath -Force | Out-Null
    Set-ItemProperty -Path $directoryCommandPath -Name "(Default)" -Value "`"$vscodePath`" `"%1`""
    Write-Host "Added directory context menu entry"
}
else {
    Write-Host "Directory context menu entry already exists"
}

# Add files context menu
Write-Host "`nAdding files context menu..."
try {
    Write-Verbose "Creating registry key: HKEY_CLASSES_ROOT\*\shell\VSCode"
    $key = [Microsoft.Win32.Registry]::ClassesRoot.OpenSubKey("*\shell", $true)
    if ($null -eq $key) {
        throw "Could not open *\shell key"
    }

    $existingVSCodeKey = $key.OpenSubKey("VSCode")
    if ($null -ne $existingVSCodeKey) {
        Write-Host "VSCode context menu entry already exists"
        $existingVSCodeKey.Close()
        $key.Close()
        return
    }

    Write-Verbose "Creating VSCode subkey"
    $vscodeKey = $key.CreateSubKey("VSCode")
    if ($null -eq $vscodeKey) {
        throw "Could not create VSCode subkey"
    }

    Write-Verbose "Setting default value"
    $vscodeKey.SetValue("", "Edit with Code")

    Write-Verbose "Setting icon"
    $vscodeKey.SetValue("Icon", "`"$vscodePath`"")

    $existingCommandKey = $vscodeKey.OpenSubKey("command")
    if ($null -ne $existingCommandKey) {
        Write-Host "Command subkey already exists"
        $existingCommandKey.Close()
    }
    else {
        Write-Verbose "Creating command subkey"
        $commandKey = $vscodeKey.CreateSubKey("command")
        if ($null -eq $commandKey) {
            throw "Could not create command subkey"
        }

        Write-Verbose "Setting command value"
        $commandKey.SetValue("", "`"$vscodePath`" `"%1`"")
        $commandKey.Close()
    }

    Write-Host "Successfully added files context menu entry"

    $vscodeKey.Close()
    $key.Close()
}
catch {
    Write-Error "Failed to add files context menu entry:"
    Write-Error $_.Exception.Message
    Write-Error $_.ScriptStackTrace
}

Write-Host "`nScript completed. Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')