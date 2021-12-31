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
alias p="cd $PLATFORM_HOME"
alias aga='ag --ignore tests'
alias kc='kubectl'

function pullpr()
{
  for pr in "$@"
  do
    i=0
    while git rev-parse --verify "pr$pr-$i"
    do
      i=$((i+1))
    done
    git fetch origin "pull/$pr/head:pr$pr-$i"
    git checkout "pr$pr-$i"
  done
}

# Start X
if [[ -z "$DISPLAY" && $(tty) == /dev/tty1 ]]
then
    exec startx
fi
