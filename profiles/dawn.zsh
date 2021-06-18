export prompt_color="$fg_brown"
export TERM=dtterm

export FZF_CTRL_R_OPTS="--reverse"
export FZF_DEFAULT_OPTS="--bind=ctrl-j:accept"
export FZF_DEFAULT_COMMAND='fd ---type f -E out --no-ignore-vcs -E "*Test.[ch]pp"'

export USE_CCACHE="Y"

PATH="/home/jimmieh/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/jimmieh/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/jimmieh/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/jimmieh/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/jimmieh/perl5"; export PERL_MM_OPT;

if [ -d "$HOME/local/tmuxifier/bin" ];
then
  export PATH="$HOME/local/tmuxifier/bin:$PATH"
  tmuxifier init - > /dev/null
  source $HOME/local/tmuxifier/completion/tmuxifier.zsh
  alias tl='tmuxifier load-window'
fi

#if [ -d "$HOME/local/dltviewer/usr" ];
#then
#  export PATH="$PATH:$HOME/local/dltviewer/usr/bin"
#  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/local/dltviewer/usr/lib
#fi

if [ -d "$HOME/local/android" ];
then
  export PATH="$HOME/local/android:$PATH"
fi

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
#export PATH="$AOSP_HOME/out/host/linux-x86/bin:$PATH"

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
      echo " ${BLUE}[${RED}$CURRENTPROJ${BLUE}]${NORM}"
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

get_git()
{
    if [ $# -ne 1 ]
    then
        echo "get_git <repo name>" 2>/dev/null
        return 1
    fi

    git clone ssh://gerrit/$1 && scp -p gerrit:hooks/commit-msg $1/.git/hooks/
}

function choose_paths()
{
    my_files="$(tmux capture-pane -Jp | pe | nauniq | fzf -m --height 20% --reverse | paste -s -)"
    BUFFER="$BUFFER $my_files"
    zle reset-prompt
}

zle -N choose_paths
bindkey "^K" choose_paths

function sme()
{
    bash --rcfile <(echo "\
        source $HOME/.bashrc && \
        pushd $AOSP_HOME && \
        source build/envsetup.sh && \
        lunch $LUNCH_IT && \
        popd")
}

function pushsel()
{
    local readonly selinux_dir="$AOSP_HOME/out/target/product/$PROJ_DEVICE/vendor/etc/selinux"
    [ -d $selinux_dir ] || { echo "error: Directory not found $selinux_dir"; return 1 }
    b :
    adb root
    b :
    adb remount
    adb push $AOSP_HOME/out/target/product/$PROJ_DEVICE/vendor/etc/selinux /vendor/etc
    adb push $AOSP_HOME/out/target/product/$PROJ_DEVICE/system/etc/selinux /system/etc
    adb reboot
}

function agseall
{
    ag --ignore prebuilts -sw "$@" $(fd -E boottime_tools -E mixins -E out --type d '^sepolicy$' "$AOSP_HOME/system" "$AOSP_HOME/device/acompany" "$AOSP_HOME/device/intel" "$AOSP_HOME/packages")
}

function j()
{
    if [[ "$#" -ne 0 ]]; then
        cd $(autojump $@)
        return
    fi
    cd "$(autojump -s | \
        sort -k1gr | \
        awk '$1 ~ /[0-9]:/ && $2 ~ /^\// { for (i=2; i<=NF; i++) { print $(i) } }' | \
        ag -v $(if [ $CURRENTPROJ != ASDF4 ]; then echo "/home/jimmieh/asdf4"; elif [ $CURRENTPROJ != ASDF2 ]; then echo "/home/jimmieh/asdf2"; fi) | \
        fzf --height 40% --reverse --inline-info)"
}


##################
# End Functions
##################

#alias runctags='ctags -R --exclude="*test*" --exclude="*[Ss]tub*" --exclude="*ctcif*" --exclude="*include*"'
alias myps="ps -leaf | grep $USER"
alias rmorig='rm **/*.orig'
alias db="docker_build"

alias ssdk="source $ASDF4_SOURCE"
alias sutsdk="source $ASDF4_UT_SOURCE"
alias win='cd /mnt/c/Users/JimmieH'
alias vcm_serial='picocom -b 115200 /dev/ttyUSB'

# navigation
alias h='cd $AOSP_HOME'
alias p='cd $PRODUCT_HOME'
alias mani='cd $AOSP_HOME/.repo/manifests'
alias se='cd $AOSP_HOME/system/sepolicy'
alias vm='vim $AOSP_HOME/.repo/manifest.xml'

# tmux alias
alias asdf41='tmuxifier load-session asdf41'
alias asdf42='tmuxifier load-session asdf42'
alias asdf21='tmuxifier load-session asdf21'
alias asdf22='tmuxifier load-session asdf22'

# Build AOSP
alias rr='run_remote'
alias m='run_remote m'
alias mm='run_remote mm'
alias mma='run_remote mma'
alias mmm='run_remote mmm'
alias mmma='run_remote mmma'
alias hmm='run_remote hmm'
#alias repo='run_remote repo'

alias rmout='run_remote rm -rf out'
alias core='ssh core-build-01'
alias aga='ag --ignore out --ignore cts --ignore tests'
alias agse='ag --ignore prebuilts'
alias agmb='ag -G "\.bp$|\.mk$" --ignore out'

alias rb='pkill -SIGTERM chromium; sleep 1; { [ ! $(command -v shutdown_win7) ] || shutdown_win7 } && systemctl reboot'
alias sd='pkill -SIGTERM chromium; sleep 1; { [ ! $(command -v shutdown_win7) ] || shutdown_win7 } && systemctl poweroff'
alias stopflicker='xrandr --output DP-1-2-1-8 --off && setmonitor.sh'
alias update_adb='cp ~/$AOSP_HOME/out/host/linux-x86/bin/{adb,fastboot,mke2fs} ~/local/android'

if [[ -z "$DISPLAY" && $(tty) == /dev/tty1 ]]
then
    startx
fi

