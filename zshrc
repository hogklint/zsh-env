##!/bin/zsh

source $HOME/.zsh/colors

alias ls='ls --color=auto'
alias grep='grep --colour=auto'
alias rm='rm -i'
alias l='ls -hl --color=auto'
alias la='ls -hla --color=auto'
alias gs='git status'
alias gd='git diff'
alias gg='git grep -W'
alias cal='cal -m'

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

setopt cshjunkiequotes #command must match qoutes
setopt noclobber # redirect to existing file with >!
setopt extended_history
setopt inc_append_history
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_expire_dups_first

if [ -d "$HOME/local/bin" ];
then
  export PATH="$HOME/local/bin:$PATH"
fi
if [ -d "$HOME/local/lib" ];
then
  export LD_LIBRARY_PATH="$HOME/local/lib:$LD_LIBRARY_PATH"
fi

export RPROMPT="%F${fg_green}%~%f"

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

function precmd()
{
  #set -x
  if [ "root" = "$USER" ];
  then
    export PROMPT="%B%F${fg_red}%m%k ${RED}$(__git_ps1 '[%s]')${fg_blue} %# %b%f%k"
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

#cat /etc/os-release | grep NAME | cut -d'"' -f 2
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
curl https://istheinternetonfire.com/status.txt

