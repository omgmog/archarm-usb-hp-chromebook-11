#!/bin/bash
pacman -Ud /systemd-212-3-armv7h.pkg.tar.xz
echo 'IgnorePkg = systemd'>>etc/pacman.conf
echo "Please Set a Root password"
passwd root
rm fix-systemd.sh

