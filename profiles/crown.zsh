export prompt_color="$fg_brown"
export TERM=dtterm

source ~/.kd_variables

# make sh
export ITFLAG=-it

# Make gpg-agent work with SSH keys
export GPG_TTY=$(tty)
#echo "UPDATESTARTUPTTY" | gpg-connect-agent > /dev/null 2>&1

# pass shift-insert clipboard
export PASSWORD_STORE_X_SELECTION=primary

declare -A MY_VENVS
MY_VENVS["cli"]=$HOME/tmp/dk_cli/dk-venv

if [ -d "$HOME/local/kd" ];
then
  export PATH="$HOME/local/kd:$PATH"
fi

# Perl (Sqitch)
PATH="/home/jhogklint/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/jhogklint/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/jhogklint/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/jhogklint/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/jhogklint/perl5"; export PERL_MM_OPT;


#######
# Alias/Functions
#

alias vo='vim ~/repos/orgmode/main.org'
alias p="cd $HEIMDALL_HOME"
alias pp="cd $PLATFORM_HOME"
alias aga='ag --ignore tests'
alias ch='rm -rf build dist heimdall_be.egg-info Heimdall_BE.egg-info instance collaborate_swagger_spec.yaml index.txt test.db'

function pullpr()
{
  remote_url=$(git config --get remote.origin.url)
  if [[ $remote_url =~ "ghe.datakitchen.io|github.com" ]]
  then
    pull_prefix="pull"
  elif [[ $remote_url =~ "gitlab.com" ]]
  then
    pull_prefix="merge-requests"
  else
    echo "error: could not determine git provider (github/gitlab)"
    return
  fi

  for pr in "$@"
  do
    i=0
    git fetch origin "$pull_prefix/$pr/head"
    while git rev-parse --verify "pr$pr-$i"
    do
      if [[ "$(git log -1 --format=%H FETCH_HEAD)" == "$(git log -1 --format=%H "pr$pr-$i")" ]]
      then
        git checkout "pr$pr-$i"
        return
      fi
      i=$((i+1))
    done
    git fetch origin "$pull_prefix/$pr/head:pr$pr-$i"
    git checkout "pr$pr-$i"
  done
}

function jenklog()
{
  url=${1/%consoleText//}
  curl -u $(pass kd/jenkins) "$url/consoleText" | vim -
}

# Start X
if [[ -z "$DISPLAY" && $(tty) == /dev/tty1 ]]
then
    exec startx
fi
