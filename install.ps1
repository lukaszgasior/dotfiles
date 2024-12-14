# Install prerequisites and dotfiles

# Check if Git is installed
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git..."
    winget install -e --id Git.Git -h --accept-source-agreements --accept-package-agreements
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Check if chezmoi is installed
if (!(Get-Command chezmoi -ErrorAction SilentlyContinue)) {
    Write-Host "Installing chezmoi..."
    winget install -e --id twpayne.chezmoi --accept-source-agreements --accept-package-agreements
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Initialize and apply dotfiles
Write-Host "Initializing dotfiles..."
chezmoi init --apply lukaszgasior/dotfiles