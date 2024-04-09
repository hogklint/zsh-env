##!/bin/zsh

source $HOME/.zsh/colors

alias ls='ls --color=auto'
alias grep='grep --colour=auto'
alias rm='rm -i'
alias l='ls -hl --color=auto'
alias la='ls -hla --color=auto'
alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias gg='git grep -W'
alias cal='cal -m'
alias hi='ag --passthrough'
alias pe='path-extractor'
alias ssh='ssh -o AddKeysToAgent=yes'
alias fds='fd --no-ignore-vcs --hidden'

bindkey -e
bindkey "^W" "vi-backward-kill-word"

#completion
autoload -U compinit
compinit

# prompt
autoload -U promptinit
promptinit

export EDITOR=vim
export PAGER=less
export LESS=-Xr
export HISTSIZE=2000000
export SAVEHIST=2000000
export HISTFILE=~/.zhistory

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

#setopt cshjunkiequotes #command must match qoutes
setopt noclobber # redirect to existing file with >!
setopt extended_history
setopt inc_append_history
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_expire_dups_first
setopt interactive_comments

extended_rprompt()
{
  PARTS=()
  if [ -n "$VIRTUAL_ENV" ]
  then
    PARTS+=("${RED}$(basename $VIRTUAL_ENV)")
  fi
  if [ "${#PARTS[@]}" -gt 0 ]; then
    echo " ${BLUE}[${RED}${PARTS[@]}${BLUE}]${NORM}"
  fi
}

function precmd()
{
  #set -x
  if [ "root" = "$USER" ];
  then
    export PROMPT="%B%F${fg_red}%m%k ${fg_blue} %# %b%f%k"
  else
    export PROMPT="%B%F${prompt_color}%n@%m%k%B%F ${RED}$(__git_ps1 '[%s]') ${fg_blue} %# %b%f%k"
  fi
  #set +x
}
RPROMPT='%F${fg_green}%~$(extended_rprompt) $(kube_ps1)%f'

export GOPATH=$HOME/local/go
PATHS=(
  "$HOME/local/bin"
  "$HOME/.local/bin"
  "$HOME/.krew/bin"
  "$HOME/local/argocd"
  "$GOPATH/bin"
)
for p in ${PATHS[@]};
do
  if [ -d "$p" ];
  then
    PATH="$p:$PATH"
  fi
done
export PATH

if [ -d "$HOME/local/lib" ];
then
  export LD_LIBRARY_PATH="$HOME/local/lib:$LD_LIBRARY_PATH"
fi

if command -v kubectl &>/dev/null;
then
  alias kc='kubectl'
fi

[ "root" = "$USER" ] && return

man()
{
  env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
    man "$@"
}


# Git
source $HOME/.zsh/completion/git
#GIT_PS1_SHOWUPSTREAM=auto
#GIT_PS1_SHOWUNTRACKEDFILES=true
#GIT_PS1_SHOWDIRTYSTATE=true
#GIT_PS1_SHOWSTASHSTATE=true
#GIT_PS1_DESCRIBE_STYLE=contains
#GIT_PS1_SHOWCOLORHINTS=true

GIT_PS1_SHOWUPSTREAM=verbose
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_DESCRIBE_STYLE=contains
GIT_PS1_SHOWCOLORHINTS=true


############################
# FZF settings and functions
#

export FZF_CTRL_R_OPTS="--reverse"
export FZF_DEFAULT_OPTS="--bind=ctrl-j:accept"
export FZF_DEFAULT_COMMAND='fd --type f --hidden -E "*Test.[ch]pp" -E ".git"'

function j() {
    if [[ "$#" -ne 0 ]]; then
        cd $(autojump $@)
        return
    fi
    cd "$(autojump -s | \
        sort -k1gr | \
        awk '$1 ~ /[0-9]:/ && $2 ~ /^\// { for (i=2; i<=NF; i++) { print $(i) } }' | \
        fzf --height 40% --reverse --inline-info)"
}

function run_j()
{
    if [ -z "$BUFFER" ]
    then
        BUFFER="j"
        zle accept-line
    fi
}
zle -N run_j
bindkey "^ " run_j

function fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  openFile="$(rg --files-with-matches --no-messages "$1" | \
      fzf --preview "highlight -O ansi -l {} 2> /dev/null | \
      rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || \
      rg --ignore-case --pretty --context 10 '$1' {}")"

  if [ -n "$openFile" ]
  then
      vim +/$1 $openFile
  fi
}

function a()
{
  if [ 0 -eq "$#" ]
  then
    TMP_VENV_PATH=".venv"
  elif [ -n "$MY_VENVS["$1"]" ]
  then
    TMP_VENV_PATH=$MY_VENVS["$1"]
  elif [ -d "$HOME/tmp/venvs/$1" ]
  then
    TMP_VENV_PATH=$HOME/tmp/venvs/$1
  else
    TMP_VENV_PATH=$1
  fi

  source "$TMP_VENV_PATH/bin/activate"
}


#################
# Import profiles
#

DIST=`cat /etc/os-release | grep NAME | grep -Eo "Arch|Gentoo" | head -1`
if [[ -f "$HOME/.zsh/profiles/$DIST.zsh" ]]
then
  source $HOME/.zsh/profiles/$DIST.zsh 2> /dev/null
fi

HOST=`hostname`
if [[ -f "$HOME/.zsh/profiles/$HOST.zsh" ]]
then
  source $HOME/.zsh/profiles/$HOST.zsh 2> /dev/null
fi


########################
# Print internet on fire
#

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if [ $(date "+%H") -lt 9 ]
then
    curl https://istheinternetonfire.com/status.txt
fi

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk
zinit light jonmosco/kube-ps1
