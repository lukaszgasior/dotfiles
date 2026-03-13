if ([Environment]::UserInteractive) {

    if ($PSStyle) {
        $PSStyle.FileInfo.Directory = "`e[38;2;255;255;255m"
        $PSStyle.FileInfo.Executable = "`e[38;2;255;255;255m"
        $PSStyle.FileInfo.SymbolicLink = "`e[38;2;255;255;255m"
        $PSStyle.FileInfo.Extension.Clear()
        $PSStyle.Formatting.TableHeader = ''
        $PSStyle.Formatting.FormatAccent = ''
        $PSStyle.Progress.View = 'Classic'
    }

    # if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
    # }

    # if (Get-Module -ListAvailable PSReadLine) {
    # $azPredictorInstalled = if (Get-Command Get-InstalledPSResource -ErrorAction SilentlyContinue) {
    #     [bool](Get-InstalledPSResource -Name Az.Tools.Predictor -ErrorAction SilentlyContinue)
    # } else {
    #     [bool](Get-Module -ListAvailable Az.Tools.Predictor)
    # }
    # $predictionSource = if ($azPredictorInstalled) { 'HistoryAndPlugin' } else { 'History' }
    # Set-PSReadLineOption -PredictionSource $predictionSource
    Set-PSReadLineOption -PredictionSource 'HistoryAndPlugin'
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -MaximumHistoryCount 10000
    Set-PSReadLineOption -HistoryNoDuplicates

    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
    Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -ScriptBlock {
        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        $selected = (Get-Content (Get-PSReadLineOption).HistorySavePath | Select-Object -Unique | fzf --tac --prompt 'History > ' --height 40% --layout reverse --query $line)
        if ($selected) {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
        }
    }

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
    # }

    # if ($azPredictorInstalled) {
    #     Import-Module Az.Tools.Predictor
    # }

    # if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    #     kubectl completion powershell | Out-String | Invoke-Expression

    #     Set-Alias -Name k -Value kubectl
    #     Register-ArgumentCompleter -CommandName k -ScriptBlock $__kubectlCompleterBlock
    # }
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
    $env:EDITOR = 'nvim'
    $env:VISUAL = 'nvim'

    Set-Alias -Name vim -Value nvim
    Set-Alias -Name vi -Value nvim
}

function Resolve-PathOnDrive {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match '^[A-Z]:\\$' }
    foreach ($drive in $drives) {
        $fullPath = Join-Path $drive.Root $RelativePath
        if (Test-Path $fullPath) { return $fullPath }
    }
}

function Find-AndNavigate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    $fullPath = Resolve-PathOnDrive $RelativePath
    if ($fullPath) { Set-Location $fullPath } else { Write-Warning "Can't find [$RelativePath]" }
}

function Set-Project {
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) { projects; return }

    $root = Resolve-PathOnDrive 'projects'
    if (-not $root) { Write-Warning 'projects folder not found'; return }

    $selected = Get-ChildItem -Path $root -Directory |
        Select-Object -ExpandProperty Name |
        fzf --prompt 'Project > ' --height 40% --layout reverse

    if ($selected) {
        Set-Location (Join-Path $root $selected)
    }
}

function projects { Find-AndNavigate 'projects' }
function github { Find-AndNavigate 'github' }
function take($Path) { mkdir $Path | Out-Null; Set-Location $Path }
function china { az cloud set --name AzureChinaCloud }
function global { az cloud set --name AzureCloud }
function winutil { irm 'https://christitus.com/win' | iex }
function getip { (Invoke-RestMethod -Uri 'https://api.ipify.org?format=json').ip }

function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

# AZURE
function Set-AzureSubscription {
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) { az account list -o table; return }
    $selected = az account list --query '[].{name:name, id:id}' -o tsv |
        fzf --prompt 'Subscription > ' --height 40% --layout reverse
    if ($selected) {
        $id = ($selected -split '\t')[1]
        az account set --subscription $id
        Write-Host "Switched to: $(($selected -split '\t')[0])" -ForegroundColor Green
    }
}

function Get-AzureContext {
    az account show --query '{Name:name, SubscriptionId:id, Tenant:tenantId, State:state}' -o table
}

function Connect-AzureInteractive {
    az login --use-device-code
}

Set-PSReadLineKeyHandler -Chord 'Alt+s' -ScriptBlock {
    Set-AzureSubscription
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}
Set-PSReadLineKeyHandler -Chord 'Alt+g' -ScriptBlock {
    Set-Project
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}

Set-Alias -Name azs -Value Set-AzureSubscription
Set-Alias -Name azc -Value Get-AzureContext
Set-Alias -Name azl -Value Connect-AzureInteractive
