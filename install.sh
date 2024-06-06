#! /bin/bash

# --------------- START OF TUI LIB -----------------
_get_cursor_row() {
  local IFS=';'
  read -sdR -p $'\E[6n' ROW COL
  echo "${ROW#*[}"
}
_cursor_blink_on() { echo -en "\033[?25h" >&2; }
_cursor_blink_off() { echo -en "\033[?25l" >&2; }
_cursor_to() { echo -en "\033[$1;$2H" >&2; }
_key_input() {
  local ESC=$'\033'
  local IFS=''
  read -rsn1 a
  if [[ "$ESC" == "$a" ]]; then
    read -rsn2 b
  fi
  local input="${a}${b}"
  case "$input" in
  "$ESC[A") echo up ;;
  "$ESC[B") echo down ;;
  "$ESC[C") echo right ;;
  "$ESC[D") echo left ;;
  '') echo enter ;;
  ' ') echo space ;;
  esac
}
_new_line_foreach_item() {
  count=0
  while [[ $count -lt $1 ]]; do
    echo "" >&2
    ((count++))
  done
}
_prompt_text() {
  echo -en "\033[32m?\033[0m\033[1m ${1}\033[0m " >&2
}
_decrement_selected() {
  local selected=$1
  ((selected--))
  if [ "${selected}" -lt 0 ]; then
    selected=$(($2 - 1))
  fi
  echo -n $selected
}
_increment_selected() {
  local selected=$1
  ((selected++))
  if [ "${selected}" -ge "${opts_count}" ]; then
    selected=0
  fi
  echo -n $selected
}
input() {
  _prompt_text "$1"
  echo -en "\033[36m\c" >&2
  read -r text
  echo -n "${text}"
}
confirm() {
  trap "_cursor_blink_on; stty echo; exit" 2
  _cursor_blink_off
  _prompt_text "$1 (y/N)"
  echo -en "\033[36m\c " >&2
  local start_row
  start_row=$(_get_cursor_row)
  local current_row
  current_row=$((start_row - 1))
  local result=""
  echo -n " " >&2
  while true; do
    echo -e "\033[1D\c " >&2
    read -n1 result
    case "$result" in
    y | Y)
      echo -n 1
      break
      ;;
    n | N)
      echo -n 0
      break
      ;;
    *) _cursor_to "${current_row}" ;;
    esac
  done
  echo -en "\033[0m" >&2
  echo "" >&2
}
list() {
  _prompt_text "$1 "
  local opts=("${@:2}")
  local opts_count=$(($# - 1))
  _new_line_foreach_item "${#opts[@]}"
  local lastrow
  lastrow=$(_get_cursor_row)
  local startrow
  startrow=$((lastrow - opts_count + 1))
  trap "_cursor_blink_on; stty echo; exit" 2
  _cursor_blink_off
  local selected=0
  while true; do
    local idx=0
    for opt in "${opts[@]}"; do
      _cursor_to $((startrow + idx))
      if [ $idx -eq $selected ]; then
        printf "\033[0m\033[36m❯\033[0m \033[36m%s\033[0m" "$opt" >&2
      else
        printf "  %s" "$opt" >&2
      fi
      ((idx++))
    done
    case $(_key_input) in
    enter) break ;;
    up) selected=$(_decrement_selected "${selected}" "${opts_count}") ;;
    down) selected=$(_increment_selected "${selected}" "${opts_count}") ;;
    esac
  done
  echo -en "\n" >&2
  _cursor_to "${lastrow}"
  _cursor_blink_on
  echo -n "${selected}"
}
checkbox() {
  _prompt_text "$1"
  local opts
  opts=("${@:2}")
  local opts_count
  opts_count=$(($# - 1))
  _new_line_foreach_item "${#opts[@]}"
  local lastrow
  lastrow=$(_get_cursor_row)
  local startrow
  startrow=$((lastrow - opts_count + 1))
  trap "_cursor_blink_on; stty echo; exit" 2
  _cursor_blink_off
  local selected=0
  local checked=()
  while true; do
    local idx=0
    for opt in "${opts[@]}"; do
      _cursor_to $((startrow + idx))
      local icon="◯"
      for item in "${checked[@]}"; do
        if [ "$item" == "$idx" ]; then
          icon="◉"
          break
        fi
      done
      if [ $idx -eq $selected ]; then
        printf "%s \e[0m\e[36m❯\e[0m \e[36m%-50s\e[0m" "$icon" "$opt" >&2
      else
        printf "%s   %-50s" "$icon" "$opt" >&2
      fi
      ((idx++))
    done
    case $(_key_input) in
    enter) break ;;
    space)
      local found=0
      for item in "${checked[@]}"; do
        if [ "$item" == "$selected" ]; then
          found=1
          break
        fi
      done
      if [ $found -eq 1 ]; then
        checked=("${checked[@]/$selected/}")
      else
        checked+=("${selected}")
      fi
      ;;
    up) selected=$(_decrement_selected "${selected}" "${opts_count}") ;;
    down) selected=$(_increment_selected "${selected}" "${opts_count}") ;;
    esac
  done
  _cursor_to "${lastrow}"
  _cursor_blink_on
  IFS="" echo -n "${checked[@]}"
}
password() {
  _prompt_text "$1"
  echo -en "\033[36m" >&2
  local password=''
  local IFS=
  while read -r -s -n1 char; do
    [[ -z "${char}" ]] && {
      printf '\n' >&2
      break
    }
    if [ "${char}" == $'\x7f' ]; then
      if [ "${#password}" -gt 0 ]; then
        password="${password%?}"
        echo -en '\b \b' >&2
      fi
    else
      password+=$char
      echo -en '*' >&2
    fi
  done
  echo -en "\e[0m" >&2
  echo -n "${password}"
}
editor() {
  tmpfile=$(mktemp)
  _prompt_text "$1"
  echo "" >&2
  "${EDITOR:-vi}" "${tmpfile}" >/dev/tty
  echo -en "\033[36m" >&2
  cat "${tmpfile}" | sed -e 's/^/  /' >&2
  echo -en "\033[0m" >&2
  cat "${tmpfile}"
}
with_validate() {
  while true; do
    local val
    val="$(eval "$1")"
    if ($2 "$val" >/dev/null); then
      echo "$val"
      break
    else
      show_error "$($2 "$val")"
    fi
  done
}
range() {
  local min="$2"
  local current="$3"
  local max="$4"
  local selected="${current}"
  local max_len_current
  max_len_current=0
  if [[ "${#min}" -gt "${#max}" ]]; then
    max_len_current="${#min}"
  else
    max_len_current="${#max}"
  fi
  local padding
  padding="$(printf "%-${max_len_current}s" "")"
  local start_row
  start_row=$(_get_cursor_row)
  local current_row
  current_row=$((start_row - 1))
  trap "_cursor_blink_on; stty echo; exit" 2
  _cursor_blink_off
  _check_range() {
    val=$1
    if [[ "$val" -gt "$max" ]]; then
      val=$min
    elif [[ "$val" -lt "$min" ]]; then
      val=$max
    fi
    echo "$val"
  }
  while true; do
    _prompt_text "$1"
    printf "\033[37m%s\033[0m \033[1;90m❮\033[0m \033[36m%s%s\033[0m \033[1;90m❯\033[0m \033[37m%s\033[0m\n" "$min" "${padding:${#selected}}" "$selected" "$max" >&2
    case $(_key_input) in
    enter)
      break
      ;;
    left)
      selected="$(_check_range $((selected - 1)))"
      ;;
    right)
      selected="$(_check_range $((selected + 1)))"
      ;;
    esac
    _cursor_to "$current_row"
  done
  echo "$selected"
}
validate_present() {
  if [ "$1" != "" ]; then return 0; else
    echo "Please specify the value"
    return 1
  fi
}
show_error() {
  echo -e "\033[91;1m✘ $1\033[0m" >&2
}
show_success() {
  echo -e "\033[92;1m✔ $1\033[0m" >&2
}
LOG_ERROR=3
LOG_WARN=2
LOG_INFO=1
LOG_DEBUG=0
parse_log_level() {
  local level="$1"
  local parsed
  case "${level}" in
  info | INFO) parsed=$LOG_INFO ;;
  debug | DEBUG) parsed=$LOG_DEBUG ;;
  warn | WARN) parsed=$LOG_WARN ;;
  error | ERROR) parsed=$LOG_ERROR ;;
  *) parsed=-1 ;;
  esac
  export LOG_LEVEL="${parsed}"
}
log() {
  local level="$1"
  local message="$2"
  local color=""
  if [[ $level -lt ${LOG_LEVEL:-$LOG_INFO} ]]; then
    return
  fi
  case "${level}" in
  "$LOG_INFO")
    level="INFO"
    color='\033[1;36m'
    ;;
  "$LOG_DEBUG")
    level="DEBUG"
    color='\033[1;34m'
    ;;
  "$LOG_WARN")
    level="WARN"
    color='\033[0;33m'
    ;;
  "$LOG_ERROR")
    level="ERROR"
    color='\033[0;31m'
    ;;
  esac
  echo -e "[${color}$(printf '%-5s' "${level}")\033[0m] \033[1;35m$(date +'%Y-%m-%dT%H:%M:%S')\033[0m ${message}"
}
detect_os() {
  case "$OSTYPE" in
  solaris*) echo "solaris" ;;
  darwin*) echo "macos" ;;
  linux*) echo "linux" ;;
  bsd*) echo "bsd" ;;
  msys*) echo "windows" ;;
  cygwin*) echo "windows" ;;
  *) echo "unknown" ;;
  esac
}
get_opener() {
  local cmd
  case "$(detect_os)" in
  macos) cmd="open" ;;
  linux) cmd="xdg-open" ;;
  windows) cmd="start" ;;
  *) cmd="" ;;
  esac
  echo "$cmd"
}
open_link() {
  cmd="$(get_opener)"
  if [ "$cmd" == "" ]; then
    echo "Your platform is not supported for opening links."
    echo "Please open the following URL in your preferred browser:"
    echo " ${1}"
    return 1
  fi
  $cmd "$1"
  if [[ $? -eq 1 ]]; then
    echo "Failed to open your browser."
    echo "Please open the following URL in your browser:"
    echo "${1}"
    return 1
  fi
  return 0
}
# ---------------- END OF TUI LIB ------------------

# export LOG_LEVEL="$LOG_DEBUG"

echo "Updating Debian..."
sudo apt install nala -y
sudo nala upgrade
echo
echo "##########################"
echo "# Trude's Debian Toolkit #"
echo "##########################"
if [ $? == 0 ]; then
  show_success "System updated."
else
  show_error "Update failed."
  exit 1
fi
echo

main_menu_opts=("Install Trude's Dotfiles" "Install DWM (desktop)" "Install GNOME (desktop)" "Install GitHub CLI" "Install Google Chrome" "Install AI" "Install Tailscale" "+Install Games")
main_menu=$(checkbox "Press SPACE to select and ENTER to continue." "${main_menu_opts[@]}")

log "$LOG_DEBUG" "Menu opts: $main_menu"

# Submenus
if [[ ${main_menu[@]} =~ 7 ]]; then # +Games
  echo "Select games to install"
  game_menu_opts=("Install MultiMC and Java 8,17,21." "Install Minecraft Bedrock" "Install Steam")
  game_menu=$(checkbox "Press SPACE to select and ENTER to continue." "${game_menu_opts[@]}")

  if [[ ${game_menu[@]} =~ 0 ]]; then # Install MultiMC
    # Install multimc
    sudo nala update
    sudo nala install libqt5core5a libqt5network5 libqt5gui5
    wget https://files.multimc.org/downloads/multimc_1.6-1.deb
    sudo nala install ./multimc_1.6-1.deb
    rm multimc_1.6-1.deb

    # Install java
    sudo mkdir -p /etc/apt/keyrings
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /etc/apt/keyrings/adoptium.asc
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
    sudo nala update
    sudo nala install temurin-8-jdk temurin-21-jdk temurin-17-jdk
  fi

  if [[ ${game_menu[@]} =~ 1 ]]; then # Install Minecraft Bedrock
    curl -sS https://minecraft-linux.github.io/pkg/deb/pubkey.gpg | sudo tee -a /etc/apt/trusted.gpg.d/minecraft-linux-pkg.asc
    echo "deb [arch=amd64,arm64,armhf] https://minecraft-linux.github.io/pkg/deb bookworm-nightly main" | sudo tee /etc/apt/sources.list.d/minecraft-linux-pkg.list
    sudo nala update
    sudo nala install mcpelauncher-manifest mcpelauncher-ui-manifest msa-manifest
  fi

  if [[ ${game_menu[@]} =~ 2 ]]; then # Install Steam
    echo "Add \"contrib non-free\" to the end of each repo. Press ENTER to edit /etc/apt/sources.list."
    read
    sudoedit /etc/apt/sources.list

    sudo dpkg --add-architecture i386
    sudo nala update
    sudo nala install mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386
    sudo nala install steam
  fi

fi

# Main menu items
if [[ ${main_menu[@]} =~ 0 ]]; then # Install Dotfiles
  sudo nala install htop fzf tmux git vim wget

  # Clone repo if needed
  if [ $(pwd) != "$HOME/dotfiles" ]; then
    cd $HOME
    git clone https://github.com/TrudeEH/dotfiles --depth=1
    cd dotfiles
  fi

  # Copy dotfiles
  cp -vrf dotfiles/.* $HOME

  # Reload Fonts
  fc-cache -f
fi

if [[ ${main_menu[@]} =~ 1 ]]; then # DWM
  sudo nala install libx11-dev libxft-dev libxinerama-dev build-essential libxrandr-dev feh xorg network-manager
  sudo systemctl start NetworkManager.service
  sudo systemctl enable NetworkManager.service
  compile() {
    cd suckless/$1
    sudo rm -rf config.h
    sudo make clean install
    cd ../..
  }

  compile dwm
  compile dmenu
  compile slock
  compile slstatus
  compile st
  compile tabbed
  compile surf
fi

if [[ ${main_menu[@]} =~ 2 ]]; then # GNOME
  sudo nala install gnome-core
  sudo rm -rf /etc/network/interfaces #Fix Wifi settings bug

  # Load settings
  if test -f ~/dotfiles/settings.dconf; then
    dconf load / < ~/dotfiles/settings.dconf
  fi
fi

if [[ ${main_menu[@]} =~ 3 ]]; then # Github CLI
  (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) &&
    sudo mkdir -p -m 755 /etc/apt/keyrings &&
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    sudo nala update &&
    sudo nala install gh -y
  if [ $? == 0 ]; then
    show_success "GitHub CLI Installed."
  else
    show_error "Failed to install Github CLI."
  fi
fi

if [[ ${main_menu[@]} =~ 4 ]]; then # Chrome
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo nala install ./google-chrome-stable_current_amd64.deb
  rm ./google-chrome-stable_current_amd64.deb
fi

if [[ ${main_menu[@]} =~ 5 ]]; then # AI
  # Ollama - LLM Server
  curl -fsSL https://ollama.com/install.sh | sh

  # Fabric - LLM Client w/ prompts
  cd ~
  git clone https://github.com/danielmiessler/fabric.git
  sudo nala install pipx ffmpeg
  cd fabric
  pipx install .
  fabric --setup
  cd ..
  rm -rf fabric
fi

if [[ ${main_menu[@]} =~ 6 ]]; then # Tailscale
  curl -fsSL https://tailscale.com/install.sh | sh
  sudo systemctl enable tailscaled
  sudo tailscale up
fi
