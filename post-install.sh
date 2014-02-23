#!/bin/bash
REPOPATH="https://raw2.github.com/omgmog/archarm-usb-hp-chromebook-11/master/"

# Update pacman and install some important things
pacman -Syyu
pacman -S mate mate-extra xorg-server xorg-xinit xorg-server-utils xterm alsa-utils xf86-video-armsoc-chromium xf86-input-synaptics
pacman -S lightdm lightdm-gtk2-greeter
systemctl enable lightdm
echo "exec mame-session" > ~/.xinitrc

# Add xorg.conf entries for screen and touchpad
cd /etc/X11/xorg.conf.d/
wget ${REPOPATH}10-monitor.conf
wget ${REPOPATH}50-touchpad.conf
