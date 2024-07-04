if ($PSStyle) {
   $PSStyle.FileInfo.Directory = $PSStyle.FileInfo.Executable = $PSStyle.FileInfo.SymbolicLink = "`e[38;2;255;255;255m" 
   $PSStyle.FileInfo.Extension.Clear()
   $PSStyle.Formatting.TableHeader = ""
   $PSStyle.Formatting.FormatAccent = ""
}

# configure starship
Invoke-Expression (&starship init powershell)

# PSReadLine config
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# Aliases
Set-Alias -Name vim -Value nvim

function dotfiles { Set-Location "C:\tools\dotfiles\" }

. "$($env:DOTFILES)\.config\terminal\tf_aliasses.ps1"
. "$($env:DOTFILES)\.config\terminal\git_aliasses.ps1"

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
