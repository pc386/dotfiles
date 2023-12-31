#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

#my stuff
alias cls=clear
alias wakeptr=~/Documents/scripts/wakeptr.sh
alias navdoc="cd ~/Documents/"
source /usr/share/nvm/init-nvm.sh
alias edit=nvim
alias navdev="cd ~/Documents/develop"
alias gl="git log --oneline"
#stuff 
if [ -f /usr/share/bash-completion/completions/git ]; then
  . /usr/share/bash-completion/completions/git
fi
