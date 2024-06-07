. ".\utils\functions.ps1"

####    powershell profile  ####
$file = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
Rename-Item $file ($file + ".bak") -ErrorAction SilentlyContinue
StowFile $file (Get-Item ".\.config\terminal\ps_profile.ps1").FullName

####    windows terminal installed  ####
$file = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Rename-Item $file ($file + ".bak") -ErrorAction SilentlyContinue
StowFile $file (Get-Item ".\.config\terminal\settings.json").FullName

####    windows terminal portable  ####
$file = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
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

####    neovim     ####
$folder = "$env:LOCALAPPDATA\nvim"
Rename-Item $folder ($folder + "-bak") -ErrorAction SilentlyContinue
StowFile $folder (Get-Item ".\nvim").FullName
