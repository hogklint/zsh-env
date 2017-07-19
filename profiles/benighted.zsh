export prompt_color="$fg_brown"
export TERM=dtterm
#export TERMINFO=/home/jhogklin/.terminfo
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/local/temp/lib:/usr/lib:$HOME/local/lib

export FZF_DEFAULT_OPTS="--bind=ctrl-j:accept"
export FZF_DEFAULT_COMMAND='ag -g "" --ignore "*Test.[ch]pp" --ignore "*\.$"'

export OUT_DIR_COMMON_BASE=$HOME/android_out

export USE_CCACHE="Y"

if [ -d "$HOME/local/tmuxifier/bin" ];
then
  export PATH="$HOME/local/tmuxifier/bin:$PATH"
  tmuxifier init - > /dev/null
  source $HOME/local/tmuxifier/completion/tmuxifier.zsh
  alias tl='tmuxifier load-window'
fi

if [ -d "$HOME/local/dltviewer/usr" ];
then
  export PATH="$PATH:$HOME/local/dltviewer/usr/bin"
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/local/dltviewer/usr/lib
fi

if [ -d "$HOME/local/android" ];
then
  export PATH="$PATH:$HOME/local/android"
fi

#if [ -f "$HOME/.asdf4_params" ]
#then
#    source "$HOME/.asdf4_params"
#fi

# autocompletion colors
eval `dircolors -b`
export ZLS_COLORS=$LS_COLORS
zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==02=01}:${(s.:.)LS_COLORS}")'

export CURRENTPROJ="ASDF2"
tmuxsession="$(tmux list-panes -F "#S")"
if [[ $tmuxsession == asdf4* ]]
then
  export CURRENTPROJ="ASDF4"
elif [[ $tmuxsession == asdf2* ]]
then
  export CURRENTPROJ="ASDF2"
fi

source $HOME/.${CURRENTPROJ}_params

##################
# Functions
##################
extended_rprompt()
{
  if [ -n "$OECORE_SDK_VERSION" ]
  then
      echo " ${BLUE}[${RED}$OECORE_SDK_VERSION${BLUE}]${NORM}"
  else
      set -x
      source $HOME/.${CURRENTPROJ}_params
      set +x
      echo " ${BLUE}[${RED}$CURRENTPROJ${BLUE} / ${RED}$USED_DISPLAY_DEVICE${BLUE}]${NORM}"
  fi
}

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

##################
# End Functions
##################

#alias runctags='ctags -R --exclude="*test*" --exclude="*[Ss]tub*" --exclude="*ctcif*" --exclude="*include*"'
alias myps='ps -leaf | grep jhogklin'
#alias chrome='chromium-browser  --proxy-server=http://webproxy.scan.bombardier.com'
alias rmorig='rm **/*.orig'

alias ssdk="source $ASDF4_SOURCE"
alias sutsdk="source $ASDF4_UT_SOURCE"
alias win='cd /mnt/c/Users/JimmieH'
alias vcm_serial='picocom -b 115200 /dev/ttyUSB'

# navigation
alias a='cd $AOSP_HOME'
alias d='cd $AOSP_HOME/device/ccompany'
alias tt='cd $AOSP_HOME/device/ccompany/asdf1_p2952'
alias vc='cd $AOSP_HOME/device/ccompany/volvoasdf4'

# tmux alias
alias asdf41='tmuxifier load-session asdf41'
alias asdf42='tmuxifier load-session asdf42'
alias asdf21='tmuxifier load-session asdf21'
alias asdf22='tmuxifier load-session asdf22'

# Build AOSP
alias ah='android_wrapper_host'
alias m='android_wrapper_host m'
alias mm='android_wrapper_host mm'
alias mmm='android_wrapper_host mmm'
alias hmm='android_wrapper_host hmm'

if [[ -z "$DISPLAY" && $(tty) == /dev/tty1 ]]
then
    startx
fi

#export http_proxy=10.236.88.106:80
#export http_proxy=asdf2egot-pr02.bcompany.net
#export https_proxy=asdf2egot-pr02.bcompany.net
