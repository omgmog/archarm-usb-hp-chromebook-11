#!/bin/bash
pacman -Sy
pacman -Rdd systemd
rm -rf /etc/systemd/*
pacman -Ud /systemd-212-3-armv7h.pkg.tar.xz
echo "Please Set a Root password"
passwd root
rm fix-systemd.sh

