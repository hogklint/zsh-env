export prompt_color="$fg_brown"

# fd -> fdfind in Mint
alias fd=fdfind
alias aga='ag --hidden'
alias suspend='slock &; systemctl suspend'
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden -E "*Test.[ch]pp" -E ".git"'

source /usr/share/autojump/autojump.sh

if command -v docker &> /dev/null
then
  source <(docker completion zsh)
fi
#export CC=/usr/bin/clang
#export CXX=/usr/bin/clang++
#export CLANG_CXX_LIBRARY="libc++"
