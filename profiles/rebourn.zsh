if [ -d "$HOME/repos/tools/rebourn" ];
then
  export PATH="$HOME/repos/tools/rebourn:$PATH"
fi

keychain --timeout 240
. ~/.keychain/${HOST}-sh
. ~/.keychain/${HOST}-sh-gpg
