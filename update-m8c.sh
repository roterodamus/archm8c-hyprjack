#!/bin/bash

REPO_URL="https://github.com/laamaa/m8c.git"
DIR_NAME="m8c"

sudo pacman -Sy --noconfirm --needed libserialport sdl3 gcc pkgconf make git

if [ -d "$DIR_NAME" ]; then
    rm -rf "$DIR_NAME"
fi

git clone "$REPO_URL"
cd "$DIR_NAME"

make
sudo make install

exit
