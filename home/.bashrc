export EDITOR="vi"
export PS1="\n[\[\e[37m\]\u\[\e[0m\]@\[\e[37;2m\]\h\[\e[0m\]] \[\e[1m\]\w \[\e[0;2m\]J:\[\e[0m\]\j\n\$ "

# Commands that should be applied only for interactive shells.
[[ $- == *i* ]] || return

HISTFILESIZE=100000
HISTSIZE=10000

shopt -s histappend
shopt -s checkwinsize
shopt -s extglob
# shopt -s globstar
# shopt -s checkjobs

alias l='ls -alh'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lhi'
alias ta='tmux attach'
alias t='tmux'
alias v='nvim'
alias t='tmux'
alias raid='sudo mdadm --detail /dev/md0'

if command -v batcat 2>&1 >/dev/null; then
  alias bat=batcat
fi

set completion-ignore-case On

export OFLAGS="--ozone-platform-hint=auto"

export PATH=$PATH:$HOME/.local/bin
