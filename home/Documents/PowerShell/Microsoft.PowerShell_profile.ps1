if ([Environment]::UserInteractive)
{

   if ($PSStyle)
   {
      $PSStyle.FileInfo.Directory = "`e[38;2;255;255;255m"
      $PSStyle.FileInfo.Executable = "`e[38;2;255;255;255m"
      $PSStyle.FileInfo.SymbolicLink = "`e[38;2;255;255;255m"
      $PSStyle.FileInfo.Extension.Clear()
      $PSStyle.Formatting.TableHeader = ''
      $PSStyle.Formatting.FormatAccent = ''
      $PSStyle.Progress.View = 'Classic'
   }

   if (Get-Command starship -ErrorAction SilentlyContinue)
   {
      Invoke-Expression (&starship init powershell)
   }

   if (Get-Module -ListAvailable PSReadLine)
   {
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
         Command          = '#b8bb26'
         Parameter        = '#83a598'
         String           = '#d79921'
         Operator         = '#fe8019'
         Variable         = '#8ec07c'
         Number           = '#d3869b'
         Member           = '#fabd2f'
         Type             = '#d65d0e'
         Comment          = '#928374'
         Keyword          = '#fb4934'
         Error            = '#cc241d'
         Selection        = '#504945'
         InlinePrediction = '#665c54'
      }
   }

   if (Get-Command kubectl -ErrorAction SilentlyContinue)
   {
      kubectl completion powershell | Out-String | Invoke-Expression

      Set-Alias -Name k -Value kubectl
      Register-ArgumentCompleter -CommandName k -ScriptBlock $__kubectlCompleterBlock
   }
}

if (Get-Command nvim -ErrorAction SilentlyContinue)
{
   $env:EDITOR = 'nvim'
   $env:VISUAL = 'nvim'

   Set-Alias -Name vim -Value nvim
   Set-Alias -Name vi -Value nvim
}

function Find-AndNavigate
{
   param(
      [Parameter(Mandatory = $true)]
      [string]$RelativePath
   )

   $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' }

   foreach ($drive in $drives)
   {
      $fullPath = Join-Path $drive.Root $RelativePath
      if (Test-Path $fullPath)
      {
         Set-Location $fullPath
         return
      }
   }

   Write-Warning "Can't find [$RelativePath]"
}

function projects { Find-AndNavigate 'projects' }
function github { Find-AndNavigate 'github' }
function take($Path) { mkdir $Path | Out-Null; Set-Location $Path }

function which ($command)
{
   Get-Command -Name $command -ErrorAction SilentlyContinue |
   Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function Get-PublicIP
{
   (Invoke-RestMethod -Uri 'https://api.ipify.org?format=json').ip
}
