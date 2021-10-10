export prompt_color="$fg_brown"
export TERM=dtterm

if [[ -z "$DISPLAY" && $(tty) == /dev/tty1 ]]
then
    startx
fi
