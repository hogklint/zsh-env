export prompt_color="$fg_brown"
export TERM=dtterm

setopt interactive_comments

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
if [ -d "$HOME/repos/gap_scripts/bin" ];
then
  export PATH="$HOME/repos/gap_scripts/bin:$PATH"
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
elif [[ $tmuxsession == asdf2qc* ]]
then
  export CURRENTPROJ="ASDF225"
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
    adb push $AOSP_HOME/out/target/product/$PROJ_DEVICE/vendor/odm/etc/selinux /vendor/odm/etc
    adb push $AOSP_HOME/out/target/product/$PROJ_DEVICE/system/etc/selinux /system/etc
    adb push $AOSP_HOME/out/target/product/$PROJ_DEVICE/product/etc/selinux /product/etc
    adb reboot
}

function agseall
{
    ag --ignore prebuilts "$@" $(fd -E boottime_tools -E mixins -E out --type d '^sepolicy$' "$AOSP_HOME/system" "$AOSP_HOME/device/acompany" "$AOSP_HOME/device/intel" "$AOSP_HOME/packages")
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

function junos()
{
    if [ "$#" -ne 2 ]
    then
        echo "Usage: junos <emea/asia/amer/china> <DSID>"
        return 1
    fi
    sudo openconnect --juniper -C "DSID=$2" access.$1.acompany.com/sslvpn --no-proxy
    #sudo openconnect --juniper -C "DSID=$1" access.$2.acompany.com/sslvpn --no-proxy -s 'vpn-slice 10.0.0.0/8'
}

function wait_for_boot_completed()
{
    while [ "$(adb shell getprop sys.boot_completed 2>/dev/null)" != 1 ]
    do
        sleep 1
    done
}

function sus()
{
    killall -s SIGTERM chromium
    while true;
    do
        echo "Suspend $(date)"
        SECONDS=0
        sudo systemctl suspend
        sleep 15
        echo "$SECONDS seconds passed"
        [ $SECONDS -gt 90 ] && break
    done
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
alias r='cd $REPO_HOME'
alias se='cd $AOSP_HOME/system/sepolicy'
alias m='cd $REPO_HOME/.repo/manifests'

# tmux alias
alias asdf41='tmuxifier load-session asdf41'
alias asdf42='tmuxifier load-session asdf42'
alias asdf21='tmuxifier load-session asdf21'
alias asdf22='tmuxifier load-session asdf22'
alias asdf2qc1='tmuxifier load-session asdf2qc1'
alias asdf2qc2='tmuxifier load-session asdf2qc2'

# Build AOSP
alias rr='run_remote'
#alias mm='run_remote mm'
#alias mma='run_remote mma'
#alias mmm='run_remote mmm'
#alias mmma='run_remote mmma'
#alias hmm='run_remote hmm'
#alias repo='run_remote repo'

alias rmout='run_remote rm -rf out'
alias core='ssh core-build-01'
alias agai='ag --ignore out --ignore cts --ignore tests'
alias agse='ag --ignore prebuilts'
alias agmb='ag -G "\.bp$|\.mk$" --ignore out'
alias aga='ag --ignore out'
alias ags='ag --skip-vcs-ignores --ignore out'

alias fds='fd -E out --no-ignore-vcs --hidden'

alias rb='pkill -SIGTERM chromium; sleep 1; { [ ! $(command -v shutdown_win7) ] || shutdown_win7 } && systemctl reboot'
alias sd='pkill -SIGTERM chromium; sleep 1; { [ ! $(command -v shutdown_win7) ] || shutdown_win7 } && systemctl poweroff'
alias stopflicker='xrandr --output DP-1-1-1-8 --off && setmonitor.sh'
alias update_adb='cp ~/$AOSP_HOME/out/host/linux-x86/bin/{adb,fastboot,mke2fs} ~/local/android'

alias pe='path-extractor'

if [[ -z "$DISPLAY" && $(tty) == /dev/tty1 ]]
then
    startx
fi

