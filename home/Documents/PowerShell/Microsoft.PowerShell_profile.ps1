if ([Environment]::UserInteractive) {

   if ($PSStyle) {
      $PSStyle.FileInfo.Directory = "`e[38;2;255;255;255m"
      $PSStyle.FileInfo.Executable = "`e[38;2;255;255;255m"
      $PSStyle.FileInfo.SymbolicLink = "`e[38;2;255;255;255m"
      $PSStyle.FileInfo.Extension.Clear()
      $PSStyle.Formatting.TableHeader = ""
      $PSStyle.Formatting.FormatAccent = ""
      $PSStyle.Progress.View = 'Classic'
   }

   if (Get-Command starship -ErrorAction SilentlyContinue) {
      Invoke-Expression (&starship init powershell)
   }

   if (Get-Module -ListAvailable PSReadLine) {
      Set-PSReadLineOption -PredictionSource History
      Set-PSReadLineOption -PredictionViewStyle ListView
      Set-PSReadLineOption -HistorySearchCursorMovesToEnd
      Set-PSReadLineOption -MaximumHistoryCount 10000

      Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
      Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
      Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
      Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
      Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord

      Set-PSReadLineOption -AddToHistoryHandler {
         param($line)
         return -not $line.StartsWith(' ')
      }

      Set-PSReadLineOption -Colors @{
         Command   = 'Cyan'
         Parameter = 'DarkCyan'
         String    = 'Green'
         Operator  = 'DarkGray'
      }
   }

   if (Get-Command kubectl -ErrorAction SilentlyContinue) {
      kubectl completion powershell | Out-String | Invoke-Expression

      Set-Alias -Name k -Value kubectl
      Register-ArgumentCompleter -CommandName k -ScriptBlock $__kubectlCompleterBlock
   }
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
   $env:EDITOR = 'nvim'
   $env:VISUAL = 'nvim'

   Set-Alias -Name vim -Value nvim
   Set-Alias -Name vi -Value nvim
}

function dotfiles { Set-Location "C:\tools\dotfiles\" }

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

function Get-PublicIP {
   (Invoke-RestMethod -Uri 'https://api.ipify.org?format=json').ip
}
