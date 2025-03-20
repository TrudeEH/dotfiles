source $HOME/.local/bin/p.sh

export EDITOR="vim"
export PS1="\n[\[\e[37m\]\u\[\e[0m\]@\[\e[37;2m\]\h\[\e[0m\]] \[\e[1m\]\w \[\e[0;2m\]J:\[\e[0m\]\j\n\$ "

extract() {
  if [ -f "$1" ]; then
    case "$1" in
    *.tar.bz2)
      command -v tar >/dev/null || p i tar
      tar xjf "$1"
      ;;
    *.tar.gz)
      command -v tar >/dev/null || p i tar
      tar xzf "$1"
      ;;
    *.bz2)
      command -v bunzip2 >/dev/null || p i bzip2
      bunzip2 "$1"
      ;;
    *.rar)
      command -v unrar >/dev/null || p i unrar
      unrar e "$1"
      ;;
    *.gz)
      command -v gunzip >/dev/null || p i gzip
      gunzip "$1"
      ;;
    *.tar)
      command -v tar >/dev/null || p i tar
      tar xf "$1"
      ;;
    *.tbz2)
      command -v tar >/dev/null || p i tar
      tar xjf "$1"
      ;;
    *.tgz)
      command -v tar >/dev/null || p i tar
      tar xzf "$1"
      ;;
    *.zip)
      command -v unzip >/dev/null || p i unzip
      unzip "$1"
      ;;
    *.Z)
      command -v uncompress >/dev/null || p i ncompress
      uncompress "$1"
      ;;
    *.7z)
      command -v 7z >/dev/null || p i p7zip
      7z x "$1"
      ;;
    *)
      echo "'$1' cannot be extracted via extract()"
      ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

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
alias t="tmux"
alias ta="tmux attach"
alias cat="bat"

set completion-ignore-case On

# bash-completion
if [[ "$OSTYPE" != "darwin"* ]] && [ ! -f /usr/share/bash-completion/bash_completion ]; then
  p i bash-completion
fi

. /usr/share/bash-completion/bash_completion

export OFLAGS="--ozone-platform-hint=auto"

export PATH=$PATH:$HOME/.local/bin
