. ".\utils\functions.ps1"

####    windows terminal  ####
$file = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
Rename-Item $file ($file + ".bak") -ErrorAction SilentlyContinue
StowFile $file (Get-Item ".\.config\terminal\ps_profile.ps1").FullName

$file = "$env:APPDATA\Local\Microsoft\Windows Terminal\settings.json"
Rename-Item $file ($file + ".bak") -ErrorAction SilentlyContinue
StowFile $file (Get-Item ".\.config\terminal\settings.json").FullName

####    vscode  ####
$file = "$env:APPDATA\Code\User\settings.json"
Rename-Item $file ($file + ".bak") -ErrorAction SilentlyContinue
StowFile $file (Get-Item ".\.config\vscode\settings.json").FullName

$file = "$env:APPDATA\Code\User\keybindings.json"
Rename-Item $file ($file + ".bak") -ErrorAction SilentlyContinue
StowFile $file (Get-Item ".\.config\vscode\keybindings.json").FullName

####    git     ####
$file = "$env:USERPROFILE\.gitconfig"
Rename-Item $file ($file + ".bak") -ErrorAction SilentlyContinue
StowFile $file (Get-Item ".\.config\home\.gitconfig").FullName

$file = "$env:USERPROFILE\.gitattributes"
Rename-Item $file ($file + ".bak") -ErrorAction SilentlyContinue
StowFile $file (Get-Item ".\.config\home\.gitattributes").FullName