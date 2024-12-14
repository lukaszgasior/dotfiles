if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-NoExit -File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -Wait -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public class FontInstaller {
        [DllImport("gdi32.dll")]
        public static extern int AddFontResource(string lpFilename);

        [DllImport("user32.dll")]
        public static extern int SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    }
"@

$chezmoiSourceDir = chezmoi source-path | Out-String
$chezmoiSourceDir = $chezmoiSourceDir.Trim()
$chezmoiBaseDir = Split-Path -Parent $chezmoiSourceDir

$fontSourcePath = Join-Path $chezmoiBaseDir "fonts\ubuntumono"
$fontDestinationPath = (Join-Path $env:windir "Fonts")

if (-not (Test-Path $fontSourcePath)) {
    Write-Error "Source directory $fontSourcePath does not exist!"
    exit 1
}

$fonts = Get-ChildItem -Path $fontSourcePath -Include "*.ttf", "*.otf" -Recurse

Write-Host "Found $($fonts.Count) font files to install..."

# Constants for Windows API
$HWND_BROADCAST = [IntPtr]0xffff
$WM_FONTCHANGE = 0x001D

foreach ($font in $fonts) {
    try {
        Write-Host "Installing font: $($font.Name)"

        $destPath = Join-Path $fontDestinationPath $font.Name
        Copy-Item -Path $font.FullName -Destination $destPath -Force

        $result = [FontInstaller]::AddFontResource($destPath)
        if ($result -eq 0) {
            throw "AddFontResource failed"
        }

        $result = [FontInstaller]::SendMessage($HWND_BROADCAST, $WM_FONTCHANGE, [IntPtr]::Zero, [IntPtr]::Zero)

        $fontName = [System.IO.Path]::GetFileName($destPath)
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $font.Name -Value $fontName -Force | Out-Null

        Write-Host "Installed: $($font.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "Error installing font $($font.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nFont installation completed" -ForegroundColor Green
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')