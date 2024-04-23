export EDITOR="codium";
export PS1="\n[\[\e[37m\]\u\[\e[0m\]@\[\e[37;2m\]\h\[\e[0m\]] \[\e[1m\]\w \[\e[0;2m\]J:\[\e[0m\]\j\n\$ ";
eval "$(zoxide init bash)"

# Commands that should be applied only for interactive shells.
[[ $- == *i* ]] || return

HISTFILESIZE=100000
HISTSIZE=10000

shopt -s histappend
shopt -s checkwinsize
shopt -s extglob
shopt -s globstar
shopt -s checkjobs

alias cat='bat'
alias cd='z'
alias ci='zi'
alias code='codium'
alias diff='batdiff'
alias l='eza -alhM --git --total-size --icons'
alias ll='eza -lhiM --git --total-size --icons --tree'
alias ls='eza --icons'
alias man='batman'
alias tree='eza --tree'

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

ncs() {
  echo "+ Syncing Nextcloud @ ~/Nextcloud"
  mkdir ~/Nextcloud &> /dev/null
  if [[ -z "$1" ]]; then
    echo "USAGE: ncs <server_url>"
    exit 1
  fi
  nextcloudcmd -u $USER --path "/SYNC" ~/Nextcloud "https://$1"
}

set completion-ignore-case On
