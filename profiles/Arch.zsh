alias reboot='echo "reboot eh?"'
alias shutdown='echo "shutdown eh?"'
alias rb='pkill -SIGTERM chromium; systemctl reboot'
alias sd='pkill -SIGTERM chromium; systemctl poweroff'
alias suspend='systemctl suspend'
alias chrome='chromium'

lastupdate()
{
  local readonly date="`grep "starting full system upgrade" /var/log/pacman.log | tail -1 | grep -Eo '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}'`"
  let thenn=`date +%s -d $date`
  let now=`date +%s -d now`
  let DIFF=$(($now - $thenn))
  let days=$(($DIFF/86400))
  if [ 20 -lt $days ]
  then
    critial="\033[01;31m"
  fi
  echo "`hostname`: Last update $date $critial($days days ago)\033[0m"
}

lastupdate

