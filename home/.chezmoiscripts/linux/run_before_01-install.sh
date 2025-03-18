#!/bin/bash

if ! command -v sudo &>/dev/null; then
  apt-get update && apt-get install -y sudo
fi

# Install some base packages
sudo apt-get update && sudo apt-get install ca-certificates curl build-essential --yes && update-ca-certificates

# Install tools
sudo apt-get install git ripgrep tmux --yes

# Install neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
sudo rm nvim-linux64.tar.gz

# Install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
sudo rm lazygit.tar.gz
sudo rm -r lazygit

# Install tfswitch
curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | sudo bash

# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -r kubectl

# Install pomo
sudo curl -L https://github.com/rwxrob/pomo/releases/latest/download/pomo-linux-amd64 -o /usr/local/bin/pomo
sudo chmod +x /usr/local/bin/pomo
complete -C pomo pomo
pomo init
pomo var set interval ""
pomo var set prefix "🍅 "
pomo var set prefixwarn "💢 "

# Configure
export XDG_CONFIG_HOME="$HOME"/.config
mkdir -p "$XDG_CONFIG_HOME"

# set up git prompt
curl -L https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh >"$HOME"/.git-prompt.sh

# fix issue with unicode support in nvim in tmux
sudo locale-gen "en_US.UTF-8"
