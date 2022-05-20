#! /bin/bash

cd /home/example
echo "Installing yay"
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
echo "Done"
echo "Installing basic apps"
yay -Y --gendb
yay -S onlyoffice teams file-roller
yay -Rsu discover
echo "Done"
echo "Install scott's default apps (discord, spotify, audio driver)? [y/n]"
read scotts_install
if [ $scotts_install == "y" ]; then
    yay -S spotify discord pulseaudio pulseaudio-alsa brave-bin nvidia
fi
