#!/bin/bash
REPOPATH="https://raw.githubusercontent.com/wamserma/archarm-usb-hp-chromebook-11/master/"

# Update pacman and install some important things
pacman -Syyu
if !(which wget)
then
	pacman -Sy wget
fi
pacman -S lxde xorg-server xorg-xinit xorg-server-utils xterm alsa-utils xf86-video-fbdev xf86-input-synaptics
echo "exec startlxde" > ~/.xinitrc

# Add xorg.conf entries for screen and touchpad
cd /etc/X11/xorg.conf.d/
wget ${REPOPATH}10-monitor.conf
wget ${REPOPATH}50-touchpad.conf

# other useful programs/software I use often
pacman -S screen packer base-devel git
pacman -S geany libreoffice-fresh
pacman -S llvm 
pacman -S ghc
