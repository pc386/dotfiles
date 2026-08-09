#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='\W\$ '

#my stuff
alias cls=clear
alias wakeptr=~/Documents/scripts/wakeptr.sh
alias navdoc="cd ~/Documents/"
source /usr/share/nvm/init-nvm.sh
alias edit=nvim
alias navdev="cd ~/Documents/develop"
alias gl="git log --oneline"
alias checkpw="upower -i /org/freedesktop/UPower/devices/battery_BAT0"
#stuff 
if [ -f /usr/share/bash-completion/completions/git ]; then
  . /usr/share/bash-completion/completions/git
fi

jsonless() {
 cat "$1" | jq -C . | less -r
}

#PATH

export PATH=$PATH:~/.npm-global/bin

# Use a bright, host-specific cursor color while connected over SSH.
# OSC 112 restores Alacritty's configured cursor color when SSH exits.
ssh() {
  local argument destination cursor_color='' previous_int_trap

  for argument in "$@"; do
    destination=${argument##*@}
    case "$destination" in
      htpc)
        cursor_color='#39FF88'
        break
        ;;
      popos)
        cursor_color='#4D9FFF'
        break
        ;;
      hillside)
        cursor_color='#FF4D67'
        break
        ;;
    esac
  done

  if [[ -n $cursor_color ]]; then
    printf '\e]12;%s\e\\' "$cursor_color"
    previous_int_trap=$(trap -p INT)
    trap 'printf "\e]112\e\\"; if [[ -n $previous_int_trap ]]; then eval "$previous_int_trap"; else trap - INT; fi' INT
  fi

  command ssh "$@"
  local status=$?

  if [[ -n $cursor_color ]]; then
    if [[ -n $previous_int_trap ]]; then
      eval "$previous_int_trap"
    else
      trap - INT
    fi
    printf '\e]112\e\\'
  fi

  return "$status"
}
