#!/bin/bash
REPOPATH="https://raw.githubusercontent.com/omgmog/archarm-usb-hp-chromebook-11/master/"

# Update pacman and install some important things
pacman -Syyu
if !(which wget)
then
	pacman -Sy wget
fi
pacman -S mesa-libgl mate xorg-server xorg-xinit xorg-server-utils xterm alsa-utils xf86-video-fbdev xf86-input-synaptics
pacman -S lightdm lightdm-gtk2-greeter
pacman -S alsa-lib alsa-utils
systemctl enable lightdm
echo "exec mate-session" > ~/.xinitrc
cp /opt/asound.state /etc/asound.state
cp -r /opt/ucm* /usr/share/alsa/ucm/

alsactl -F -f /etc/asound.state restore
alsaucm -c DAISY-I2S

rm -rf /opt/*
# Add xorg.conf entries for screen and touchpad
cd /etc/X11/xorg.conf.d/
wget ${REPOPATH}10-monitor.conf
wget ${REPOPATH}50-touchpad.conf
