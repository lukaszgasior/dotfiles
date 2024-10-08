# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# keybinds
bind -x '"\C-l":clear'

# start or attach to tmux
if command -v tmux > /dev/null 2>&1; then
    if [ -z "$TMUX" ]; then
        TMUX_SESSION=$(tmux list-sessions 2>/dev/null)

        if [ -n "$TMUX_SESSION" ]; then
            tmux attach-session
        else
            tmux new-session
        fi
    fi
fi

# history
HISTCONTROL=ignorespace
HISTSIZE=25000
HISTFILESIZE=25000

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

export LANG=en_US.UTF-8
export VISUAL=nvim
export EDITOR=nvim
export TERM="tmux-256color"

# PROMPT
source "$HOME"/.git-prompt.sh

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_DESCRIBE_STYLE="branch"
PROMPT_COMMAND='__git_ps1 "\[\e[33m\]\u\[\e[0m\]@\[\e[34m\]\h\[\e[0m\]:\[\e[35m\]\w\[\e[0m\]" " \n$ "'
# END PROMPT

# DIRECTORIES
export REPOS="$HOME/repos"
export GITUSER="lukaszgasior"
export GHREPOS="$REPOS/github.com/$GITUSER"
export DOTFILES="$GHREPOS/dotfiles"
export LAB="$GHREPOS/homelab"

# PATH
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH="$PATH:/opt/nvim-linux64/bin"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/bin"
export KUBECONFIG=~/.kube/config

# ALIASES
alias vim='nvim'
alias vi='nvim'
alias ssh='ssh.exe'
alias ssh-add='ssh-add.exe'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias lab='cd $LAB'
alias dot='cd $GHREPOS/dotfiles'
alias repos='cd $REPOS'
alias ghrepos='cd $GHREPOS'

alias gp='git pull'
alias gs='git status'
alias lg='lazygit'

alias tf='terraform'
alias tp='terraform plan'

# k8s aliases and completion
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k

# bash vi mode
set -o vi

# This function is stolen from rwxrob
clone() {
  local repo="$1" user
  local repo="${repo#https://github.com/}"
  local repo="${repo#git@github.com:}"
  if [[ $repo =~ / ]]; then
    user="${repo%%/*}"
  else
    user="$GITUSER"
    [[ -z "$user" ]] && user="$USER"
  fi
  local name="${repo##*/}"
  local userd="$REPOS/github.com/$user"
  local path="$userd/$name"
  [[ -d "$path" ]] && cd "$path" && return
  mkdir -p "$userd"
  cd "$userd"
  echo gh repo clone "$user/$name" -- --recurse-submodule
  gh repo clone "$user/$name" -- --recurse-submodule
  cd "$name"
} && export -f clone

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
