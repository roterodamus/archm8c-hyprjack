# ArchM8C-HyprJack: A Simple Bash Script for a Dirtywave M8 Console

This repository has a simple Bash script that turns your (old)computer into an "M8C Console" for the Dirtywave M8 or the Dirtywave M8 Headless. 
It uses Jack as audio server and sets up the right audio and MIDI connections. It also uses Hyprland to show a floating window of M8C in the center of the screen with a nice background.


## Prerequisites

This script is designed for use on a fresh minimal Arch Linux system with the following requirements:

- An active internet connection
- A user account with sudo privileges
- Git

Install Arch Linux using the `archinstall` script for simplicity.

>1. Select your local mirror location.
>2. Enter disk configuration, use best effort on your desired drive and select ext4 filesystem.
>3. make a user account with sudo privileges.
>4. Enter additional packages to install, and type `git` then press enter
>5. Select your timezone.
>6. Enter configure network, select use networkmanager.
>7. Install.


## Installation Instructions


1. Clone the repository:
   ```bash
   git clone https://github.com/roterodamus/archm8c-hyprjack.git
   ```

2. Navigate to the cloned directory:
   ```bash
   cd archm8c-hyprjack
   ```

3. Make the installation script executable:
   ```bash
   chmod +x init.sh
   ```

4. Run the installation script:
   ```bash
   ./init.sh
   ```
## Post install

1. wip:
   ```bash
   tba
   ```
   

## Basic Keybindings Overview

**SUPER = WindowsKey or similar**

- **Launch Terminal**: `SUPER + Q` 
- **Kill Active Window**: `SUPER + C`
- **Launch File Manager**: `SUPER + E`
- **Open Menu**: `SUPER + SPACE`
- **Switch to Workspace 1 - 10**: `SUPER + 1 - 0`
- **Move to Workspace 1 - 10**: `SUPER + SHIFT + 1 - 0`

## A very special thanks to:

- Trash80 - [Dirtywave](https://dirtywave.com/)
- Laamaa  - [M8C](https://github.com/laamaa/m8c)
- and the entire FOSS Linux community.
