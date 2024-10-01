export LANG=en_US.UTF-8

source "$HOME"/.git-prompt.sh

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
# Explicitly unset color (default anyhow). Use 1 to set it.
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_DESCRIBE_STYLE="branch"
# export GIT_PS1_SHOWUPSTREAM="auto git"

PROMPT_COMMAND='__git_ps1 "\[\e[33m\]\u\[\e[0m\]@\[\e[34m\]\h\[\e[0m\]:\[\e[35m\]\w\[\e[0m\]" " \n$ "'

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH="$PATH:/opt/nvim-linux64/bin"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/bin"
export KUBECONFIG=~/.kube/config

alias vim='nvim'
alias ssh='ssh.exe'
alias ssh-add='ssh-add.exe'

source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k

set -o vi
