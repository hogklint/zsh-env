export prompt_color="$fg_brown"

# make sh
export ITFLAG=-it

# Make gpg-agent work with SSH keys
export GPG_TTY=$(tty)
#echo "UPDATESTARTUPTTY" | gpg-connect-agent > /dev/null 2>&1

# pass shift-insert clipboard
export PASSWORD_STORE_X_SELECTION=primary

# Perl (Sqitch)
#PATH="$HOME/local/perl5/bin${PATH:+:${PATH}}"; export PATH;
#PERL5LIB="$HOME/local/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
#PERL_LOCAL_LIB_ROOT="$HOME/local/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
#PERL_MB_OPT="--install_base \"$HOME/local/perl5\""; export PERL_MB_OPT;
#PERL_MM_OPT="INSTALL_BASE=$HOME/local/perl5"; export PERL_MM_OPT;


#######
# Alias/Functions
#

alias vo='vim ~/repos/orgmode/main.org'
alias p="cd $PLATFORM_HOME"
alias aga='ag --ignore tests'
alias kc='kubectl'

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

# Start X
if [[ -z "$DISPLAY" && $(tty) == /dev/tty1 ]]
then
    exec startx
fi
