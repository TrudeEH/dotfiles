export EDITOR="gnome-text-editor"
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
alias unp='unp -U' # Extract any file type

if command -v batcat 2>&1 >/dev/null; then
  alias bat=batcat
fi

set completion-ignore-case On

# Enable programmable completion features (loads all available completions)
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Set SSH_AUTH_SOCK to use gnome-keyring via GCR
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

export PATH=$PATH:$HOME/.local/bin
