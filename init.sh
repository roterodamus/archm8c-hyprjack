#!/bin/bash

# Use the current logged-in user's username
USERNAME="$USER"

# Add the user to the audio and uucp groups
sudo usermod -aG audio,uucp "$USERNAME"

# Install the required packages
sudo pacman -Syu --noconfirm --needed libserialport sdl3 gcc pkgconf make git hyprland kitty dolphin wofi nano brightnessctl swaybg alsa-utils a2jmidid jack2 jack-example-tools linux-headers xf86-input-libinput libinput xpad

# Make laucher script executable
chmod +x jack-m8c.sh
chmod +x update-m8c.sh

# Download and install m8c
git clone https://github.com/laamaa/m8c.git
cd m8c
make
sudo make install
cd ..

# Load the xpad module
sudo modprobe xpad

# Append limits to /etc/security/limits.conf
{
    echo "$USERNAME   hard    memlock     unlimited"
    echo "$USERNAME   soft    memlock     unlimited"
    echo "$USERNAME   hard    rtprio      99"
    echo "$USERNAME   soft    rtprio      99"
} | sudo tee -a /etc/security/limits.conf

# Create the directory for the autologin configuration if it doesn't exist
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/

# Create the autologin configuration file with the specified ExecStart format
{
    echo "[Service]"
    echo "ExecStart="
    echo "ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin $USERNAME %I \$TERM"
} | sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf

# Append the specified lines to the end of .bash_profile
{
    echo 'if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then'
    echo '    exec hyprland'
    echo 'fi'
} >> "$HOME/.bash_profile"

# Copy the hyprland.conf file to the .config/hypr/ directory
if [ -f "./hyprland.conf" ]; then
    echo "Found hyprland.conf, proceeding to copy."
    mkdir -p "$HOME/.config/hypr"
    cp "./hyprland.conf" "$HOME/.config/hypr/" || echo "Failed to copy hyprland.conf"
else
    echo "hyprland.conf file not found in the script directory."
fi

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

