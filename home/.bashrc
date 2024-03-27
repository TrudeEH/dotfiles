#
# ~/.bashrc
#

source ~/dotfiles/scripts/p.sh

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='\n[\[\e[37m\]\u\[\e[0m\]@\[\e[37;2m\]\h\[\e[0m\]] \[\e[1m\]\w \[\e[0;2m\]J:\[\e[0m\]\j\n\$ '

bind -s 'set completion-ignore-case on'

compress() {
    FILE=$1
    shift
    case $FILE in
    *.tar.bz2) tar cjf $FILE $* ;;
    *.tar.gz) tar czf $FILE $* ;;
    *.tgz) tar czf $FILE $* ;;
    *.zip) zip $FILE $* ;;
    *.rar) rar $FILE $* ;;
    *) echo "Filetype not recognized" ;;
    esac
}

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
