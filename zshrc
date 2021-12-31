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
export HISTSIZE=2000000
export SAVEHIST=2000000
export HISTFILE=~/.zhistory

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

setopt cshjunkiequotes #command must match qoutes
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
  if [ -n "$VIRTUAL_ENV" ]
  then
    echo " ${BLUE}[${RED}$(basename $VIRTUAL_ENV)${BLUE}]${NORM}"
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

  xrp="$(extended_rprompt 2> /dev/null)"
  if [ 0 -eq $? ];
  then
    export RPROMPT="%F${fg_green}%~${xrp}%f"
  fi
}


if [ -d "$HOME/local/bin" ];
then
  export PATH="$HOME/local/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ];
then
  export PATH="$HOME/.local/bin:$PATH"
fi

export GOPATH=$HOME/local/go
if [ -d "$GOPATH/bin" ];
then
  export PATH="$GOPATH/bin:$PATH"
fi

if [ -d "$HOME/local/lib" ];
then
  export LD_LIBRARY_PATH="$HOME/local/lib:$LD_LIBRARY_PATH"
fi

export RPROMPT="%F${fg_green}%~%f"

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
export FZF_DEFAULT_COMMAND='fd ---type f -E out --no-ignore-vcs -E "*Test.[ch]pp"'

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

function choose_paths()
{
    my_files="$(tmux capture-pane -Jp | pe | nauniq | fzf -m --height 20% --reverse | paste -s -)"
    BUFFER="$BUFFER $my_files"
    zle reset-prompt
}
zle -N choose_paths
bindkey "^K" choose_paths


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
