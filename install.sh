#! /bin/bash

# Sudo auth
auth() {
  echo "$sudopass" | sudo -S -k $*
}
export HISTIGNORE='*sudo -S*'
for (( ; ; )); do
  sudopass=$(zenity --password)
  if [ -z "${sudopass}" ]; then
    exit
  fi
  auth echo "Test sudo password."
  if [[ $? == 0 ]]; then
    break
  fi
done

if ! command -v zenity; then
  auth apt-get install zenity -y
fi

# Update System
(
  auth apt-get update
  echo "20"
  echo "# Updating distro packages..."
  auth apt-get dist-upgrade -y
  echo "40"
  echo "# Updating installed packages..."
  auth apt-get upgrade -y
  echo "60"
  echo "# Cleaning cache..."
  auth apt-get clean
  echo "80"
  echo "# Removing unused dependencies..."
  auth apt-get autoremove -y
  echo "100"
) |
  zenity --progress --title="Update System" --text="Updating repositories..." --percentage=0 --no-cancel

# Dotfiles
zenity --question \
  --title="Dotfiles" \
  --text="Apply Trude's configuration files?"

if [[ $? == 0 ]]; then
  (
    auth apt-get install -y htop fzf git wget curl bash-completion
    echo "20"
    echo "# Copying dotfiles..."
    cp -vrf config-files/.* $HOME
    echo "40"
    cp -vrf config-files/* $HOME
    echo "50"
    echo "# Configure GNOME/GTK..."
    dconf load -f / <./settings.dconf
    echo "60"
    echo "# Reloading font cache..."
    fc-cache -f
    echo "100"
  ) |
    zenity --progress --title="Configuration" --text="Installing common utilities..." --percentage=0 --no-cancel
fi

# Flatpak
zenity --question \
  --title="Install Apps" \
  --text="Enable Flatpak support?"

if [[ $? == 0 ]]; then
  (
    auth apt-get install -y flatpak
    echo "30"
    echo "# Install the gnome-software plugin..."
    auth apt-get install -y gnome-software-plugin-flatpak
    echo "50"
    echo "# Add Flathub..."
    auth flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    echo "75"
    echo "# Installing Adw GTK3 theme for flatpak apps..."
    flatpak install org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
    echo "100"
  ) |
    zenity --progress --title="Enabling Flatpak" --text="Installing Flatpak..." --percentage=0 --no-cancel
fi

# Debian Apps
options=(
  FALSE "Install Neovim"
  FALSE "Install Zed"
  FALSE "Install Ollama"
  FALSE "Install GitHub CLI"
  FALSE "Install Tailscale"
  FALSE "Install Firefox + Adw theme"
)
checkbox=$(zenity --list --checklist --height=500 --title="Install Apps" \
  --column="Select" \
  --column="Tasks" "${options[@]}")
readarray -td '|' choices < <(printf '%s' "$checkbox")

for selection in "${choices[@]}"; do
  if [ "$selection" = "Install Neovim" ]; then
    (
      auth apt install -y ninja-build gettext cmake unzip curl build-essential
      echo "30"
      git clone https://github.com/neovim/neovim --depth 1
      echo "50"
      cd neovim
      git checkout stable
      echo "60"
      make CMAKE_BUILD_TYPE=RelWithDebInfo
      echo "80"
      auth make install
      cd ..
      rm -rf neovim
      echo "100"
    ) |
      zenity --progress --title="Neovim" --text="Installing Neovim..." --percentage=0 --no-cancel
  fi

  if [ "$selection" = "Install Zed" ]; then
    zenity --notification --window-icon="info" --text="Installing Zed..."
    curl https://zed.dev/install.sh | sh
    if [[ $? == 0 ]]; then
      zenity --notification --window-icon="info" --text="Zed is now installed."
    else
      zenity --notification --window-icon="error" --text="Zed failed to install."
    fi
  fi

  if [ "$selection" = "Install Ollama" ]; then
    zenity --notification --window-icon="info" --text="Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | auth sh
    if [[ $? == 0 ]]; then
      zenity --notification --window-icon="info" --text="Ollama is now installed."
    else
      zenity --notification --window-icon="error" --text="Ollama failed to install."
    fi
  fi

  if [ "$selection" = "Install GitHub CLI" ]; then
    (
      auth apt-get install wget -y
      echo "20"
      auth mkdir -p -m 755 /etc/apt/keyrings
      auth rm -f /etc/apt/sources.list.d/github-cli.list
      wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | auth tee /etc/apt/keyrings/githubcli-archive-keyring.gpg
      echo "40"
      auth chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | auth tee /etc/apt/sources.list.d/github-cli.list
      auth apt-get update
      echo "60"
      auth apt-get install gh -y
      echo "100"
    ) |
      zenity --progress --title="GitHub CLI" --text="Installing GitHub CLI..." --percentage=0 --no-cancel
  fi

  if [ "$selection" = "Install Tailscale" ]; then
    (
      curl -fsSL https://tailscale.com/install.sh | sh
      echo "80"
      auth tailscale up
      echo "100"
    ) |
      zenity --progress --title="Tailscale" --text="Installing Tailscale..." --percentage=0 --no-cancel
  fi

  if [ "$selection" = "Install Firefox + Adw theme" ]; then
    (
      auth apt install -y firefox-esr
      echo "60"
      firefox &
      sleep 5
      echo "80"
      echo "# Applying Adw theme..."
      curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
      echo "100"
    ) |
      zenity --progress --title="Firefox" --text="Installing Firefox..." --percentage=0 --no-cancel
  fi
done

# Flatpak Apps
if command -v flatpak; then
  options=(
    FALSE "io.github.mrvladus.List" "Errands (Tasks)"
    TRUE "io.gitlab.news_flash.NewsFlash" "Newsflash (RSS)"
    FALSE "org.gnome.gitlab.somas.Apostrophe" "Apostrophe (Markdown Editor)"
    TRUE "org.gnome.World.Secrets" "Secrets (Password manager)"
    FALSE "org.gnome.Polari" "Polari (IRC)"
    TRUE "org.gnome.Fractal" "Fractal (Matrix)"
    TRUE "so.libdb.dissent" "Dissent (Discord)"
    TRUE "io.gitlab.adhami3310.Impression" "Impression (Disk image creator)"
    FALSE "org.gnome.Builder" "Builder (IDE)"
    FALSE "org.gnome.design.AppIconPreview" "App Icon Preview"
    FALSE "org.gnome.design.IconLibrary" "Icon Library"
    FALSE "org.gnome.design.Palette" "Color Palette"
    FALSE "org.gnome.design.SymbolicPreview" "Symbolic Preview"
    FALSE "org.gnome.design.Typography" "Typography"
    FALSE "re.sonny.Workbench" "Workbench"
    TRUE "org.prismlauncher.PrismLauncher" "Prism Launcher"
    TRUE "md.obsidian.Obsidian" "Obsidian"
  )
  checkbox=$(zenity --list --checklist --width=800 --height=600 \
    --title="Install Apps" \
    --column="Select" \
    --column="App ID" \
    --column="App Name" "${options[@]}")
  readarray -td '|' choices < <(printf '%s' "$checkbox")

  declare -i app_counter=0
  declare -i app_total="${#choices[@]}"

  for app in "${choices[@]}"; do
    app_counter+=1
    echo "Installing $app ($app_counter/$app_total)..."
    zenity --notification --icon="info" --text="Installing $app ($app_counter/$app_total)..."
    flatpak install -y flathub $app
    if [[ $? == 0 ]]; then
      zenity --notification --icon="info" --text="$app is now installed."
    else
      zenity --notification --icon="error" --text="$app failed to install."
    fi
  done
fi
