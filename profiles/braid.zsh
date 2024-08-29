export prompt_color="$fg_brown"

# fd -> fdfind in Mint
alias fd=fdfind
alias aga='ag --hidden'
alias suspend='slock &; systemctl suspend'
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden -E "*Test.[ch]pp" -E ".git"'

export N_PREFIX=$HOME/.cache/n
export PATH=$N_PREFIX/bin:$HOME/.pulumi/bin:$PATH

# Disable corepack always setting packageManager field in package.json
export COREPACK_ENABLE_AUTO_PIN=0

# add Pulumi to the PATH
export PATH=$PATH:$HOME/.pulumi/bin

source /usr/share/autojump/autojump.sh

if command -v docker &> /dev/null
then
  source <(docker completion zsh)
fi
#export CC=/usr/bin/clang
#export CXX=/usr/bin/clang++
#export CLANG_CXX_LIBRARY="libc++"

function pullpr()
{
  remote_url=$(git config --get remote.origin.url)
  if [[ $remote_url =~ "github.com" ]]
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
