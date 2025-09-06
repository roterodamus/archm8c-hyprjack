#!/bin/bash

# Use the current logged-in user's username
USERNAME="$USER"

# Add the user to the audio and uucp groups
sudo usermod -aG audio,uucp "$USERNAME"

# Install the required packages
sudo pacman -Syu --noconfirm --needed sway brightnessctl nano alsa-utils a2jmidid jack2 jack-example-tools linux-headers xf86-input-libinput libinput xpad bluez bluez-utils \
hyprland kitty dolphin wofi swaybg blueberry

# Make laucher script executable
chmod +x jack-m8c.sh
chmod +x update-m8c.sh

# Download and install m8c
git clone https://aur.archlinux.org/m8c.git
cd m8c/
makepkg -si
cd ..

# download and install bluetooth autoconnect
git clone https://aur.archlinux.org/bluetooth-autoconnect.git
cd bluetooth-autoconnect/
makepkg -si
cd ..

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

