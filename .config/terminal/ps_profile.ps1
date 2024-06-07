# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Install modules
$modules = @('posh-git', 'Terminal-Icons', 'ZLocation')

foreach ( $module_name in $modules ) {
   if (-not (Get-Module $module_name -ListAvailable)) {
      Install-Module $module_name -Scope CurrentUser -Force
   }
   else {
      Import-Module $module_name
   }
}

# Configure on-my-posh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\half-life.omp.json" | Invoke-Expression

# PSReadLine config
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# Aliases
Set-Alias -Name vim -Value nvim

function Get-OriginalPath {
   param (
      [string]$path
)

   $item = Get-Item $path
   if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
      return $item.LinkTarget
   } else {
      return $path
   }
}

$originalProfilePath = Get-OriginalPath -path "$PSScriptRoot\Microsoft.PowerShell_profile.ps1"
$originalLocation = Get-Item $originalProfilePath
. "$($originalLocation.Directory)\tf_aliasses.ps1"

# PoSh won't allow ${function:..} because of an invalid path error, so...
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation
${function:...} = { Set-Location ..\.. }
${function:....} = { Set-Location ..\..\.. }
${function:.....} = { Set-Location ..\..\..\.. }
${function:......} = { Set-Location ..\..\..\..\.. }

# Custom functions
function take {
   [CmdletBinding()]
   param(
      [Parameter(Mandatory = $true)]
      $Path
   )
   New-Item -Path $Path -ItemType Directory | Out-Null
   Set-Location -Path $Path
}

function which ($command) {
   Get-Command -Name $command -ErrorAction SilentlyContinue |
   Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function sudo() {
   if ($args.Length -eq 1) {
      start-process $args[0] -verb "runAs"
   }
   if ($args.Length -gt 1) {
      start-process $args[0] -ArgumentList $args[1..$args.Length] -verb "runAs"
   }
}

function grep {
  $input | out-string -stream | select-string $args
}