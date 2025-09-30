#!/bin/bash

# Use the current logged-in user's username
USERNAME="$USER"

# =======================================================
# Install chaotic aur & yay
# =======================================================

# Only add Chaotic-AUR if the architecture is x86_64 so ARM users can build the packages
if [[ "$(uname -m)" == "x86_64" ]]; then
  # Try installing Chaotic-AUR keyring and mirrorlist
  if ! pacman-key --list-keys 3056513887B78AEB >/dev/null 2>&1 &&
    sudo pacman-key --recv-key 3056513887B78AEB &&
    sudo pacman-key --lsign-key 3056513887B78AEB &&
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' &&
    sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'; then

    # Add Chaotic-AUR repo to pacman config
    if ! grep -q "chaotic-aur" /etc/pacman.conf; then
      echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf >/dev/null
    fi

    # Install yay directly from Chaotic-AUR
    sudo pacman -Sy --needed --noconfirm yay
  else
    echo "Failed to install Chaotic-AUR, so won't include it in pacman config!"
  fi
fi

# Manually install yay from AUR if not already available
if ! command -v yay &>/dev/null; then
  # Install build tools
  sudo pacman -Sy --needed --noconfirm base-devel
  rm -rf yay-bin
  git clone https://aur.archlinux.org/yay-bin.git
  cd yay-bin
  makepkg -si --noconfirm
  cd -
  rm -rf yay-bin
fi

# Add fun and color to the pacman installer
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
  sudo sed -i '/^\[options\]/a Color\nILoveCandy' /etc/pacman.conf
fi


# Add the user to the audio and uucp groups
sudo usermod -aG audio,uucp "$USERNAME"

# Install the required packages
sudo yay -Syu --noconfirm --needed sway brightnessctl nano alsa-utils a2jmidid jack2 jack-example-tools linux-headers xf86-input-libinput libinput xpad bluez bluez-utils \
kitty dolphin wofi swaybg blueberry m8c bluetooth-autoconnect greetd greetd-tuigreet

# Make laucher script executable
chmod +x jack-m8c.sh
chmod +x update-m8c.sh


# enable bluetooth services & Load the xpad module
sudo systemctl enable bluetooth.service
sudo systemctl enable bluetooth-autoconnect
sudo modprobe xpad

# Append limits to /etc/security/limits.conf
{
    echo "$USERNAME   hard    memlock     unlimited"
    echo "$USERNAME   soft    memlock     unlimited"
    echo "$USERNAME   hard    rtprio      99"
    echo "$USERNAME   soft    rtprio      99"
} | sudo tee -a /etc/security/limits.conf

# =======================================================
# Install greeter (future plans: configure autologin)
# =======================================================

sudo mkdir -p /etc/greetd
cat <<EOF | sudo tee /etc/greetd/config.toml > /dev/null
[terminal]
vt = 1

[initial_session]
command = "sway"
user = "$(whoami)"

[default_session]
command = "tuigreet --cmd 'sway'"
user = "$(whoami)"
EOF

sudo systemctl enable greetd.service
sudo systemctl set-default graphical.target

# Copy the hyprland.conf file to the .config/hypr/ directory
mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.config/sway"
cp "./hyprland.conf" "$HOME/.config/hypr/"
cp "./config" "$HOME/.config/sway/"

# Create the directory for gamecontrollerdb if it doesn't exist
mkdir -p "$HOME/.local/share/m8c/"

# Download gamecontrollerdb.txt
echo "Downloading gamecontrollerdb.txt..."
curl -o "$HOME/.local/share/m8c/gamecontrollerdb.txt" https://raw.githubusercontent.com/mdqinc/SDL_GameControllerDB/master/gamecontrollerdb.txt

# Prompt for reboot
read -p "Script completed. Would you like to reboot now? (y/n): " REBOOT
if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
    reboot
else
    echo "Please reboot for the changes to take effect."
fi

