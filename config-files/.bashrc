export EDITOR="nvim"
export PS1="\n[\[\e[37m\]\u\[\e[0m\]@\[\e[37;2m\]\h\[\e[0m\]] \[\e[1m\]\w \[\e[0;2m\]J:\[\e[0m\]\j\n\$ "

extract() {
  if [ -f $1 ]; then
    case $1 in
    *.tar.bz2) tar xjf $1 ;;
    *.tar.gz) tar xzf $1 ;;
    *.bz2) bunzip2 $1 ;;
    *.rar) unrar e $1 ;;
    *.gz) gunzip $1 ;;
    *.tar) tar xf $1 ;;
    *.tbz2) tar xjf $1 ;;
    *.tgz) tar xzf $1 ;;
    *.zip) unzip $1 ;;
    *.Z) uncompress $1 ;;
    *.7z) 7z x $1 ;;
    *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

pushall() {
  if [[ -z "$1" ]]; then
    echo "Usage: pushall \"commit message\""
  else
    git pull
    git diff
    read -p "Press ENTER to continue..."
    git add -A
    git commit -m "$@"
    git push
  fi
}

hex2color() {
  hex=${1#"#"}
  r=$(printf '0x%0.2s' "$hex")
  g=$(printf '0x%0.2s' ${hex#??})
  b=$(printf '0x%0.2s' ${hex#????})
  printf '%03d' "$(((r < 75 ? 0 : (r - 35) / 40) * 6 * 6 + (\
  g < 75 ? 0 : (g - 35) / 40) * 6 + (\
  b < 75 ? 0 : (b - 35) / 40) + 16))"
}

color2hex() {
  dec=$(($1 % 256)) ### input must be a number in range 0-255.
  if [ "$dec" -lt "16" ]; then
    bas=$((dec % 16))
    mul=128
    [ "$bas" -eq "7" ] && mul=192
    [ "$bas" -eq "8" ] && bas=7
    [ "$bas" -gt "8" ] && mul=255
    a="$(((bas & 1) * mul))"
    b="$((((bas & 2) >> 1) * mul))"
    c="$((((bas & 4) >> 2) * mul))"
    printf 'dec= %3s basic= #%02x%02x%02x\n' "$dec" "$a" "$b" "$c"
  elif [ "$dec" -gt 15 ] && [ "$dec" -lt 232 ]; then
    b=$(((dec - 16) % 6))
    b=$((b == 0 ? 0 : b * 40 + 55))
    g=$(((dec - 16) / 6 % 6))
    g=$((g == 0 ? 0 : g * 40 + 55))
    r=$(((dec - 16) / 36))
    r=$((r == 0 ? 0 : r * 40 + 55))
    printf 'dec= %3s color= #%02x%02x%02x\n' "$dec" "$r" "$g" "$b"
  else
    gray=$(((dec - 232) * 10 + 8))
    printf 'dec= %3s  gray= #%02x%02x%02x\n' "$dec" "$gray" "$gray" "$gray"
  fi
}

# Commands that should be applied only for interactive shells.
[[ $- == *i* ]] || return

HISTFILESIZE=100000
HISTSIZE=10000

shopt -s histappend
shopt -s checkwinsize
shopt -s extglob
shopt -s globstar
shopt -s checkjobs

alias l='ls -alh'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lhi'
alias ta='tmux attach'
alias t='tmux'
alias v='nvim'
alias cpp='rsync -ah --progress'
alias code='code --enable-features=UseOzonePlatform --ozone-platform=wayland'

set completion-ignore-case On

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] &&
  . /usr/share/bash-completion/bash_completion

export OFLAGS="--ozone-platform-hint=auto"

export PATH=$PATH:/home/trude/.local/bin
