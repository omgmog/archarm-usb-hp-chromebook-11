Arch ARM USB installer for the HP Chromebook 11
============================


A write-up of the process can be found here: [http://blog.omgmog.net/post/installing-arch-linux-arm-on-the-hp-chromebook-11/](http://blog.omgmog.net/post/installing-arch-linux-arm-on-the-hp-chromebook-11/)

A video of the process can be found here: [http://blog.omgmog.net/post/video-installing-arch-linux-arm-on-the-hp-chromebook-11/](http://blog.omgmog.net/post/video-installing-arch-linux-arm-on-the-hp-chromebook-11/)


## Derived from the following:

- [https://gist.github.com/cochrandv/8403647](https://gist.github.com/cochrandv/8403647)
- [http://archlinuxarm.org/platforms/armv7/samsung/samsung-chromebook](http://archlinuxarm.org/platforms/armv7/samsung/samsung-chromebook)

## Prerequisits:

- Enabled developer mode
- Enabled booting from USB devices
- A USB stick (2GB should be fine)


## To use this script

On your Chromebook with Developer Mode enabled:

```
sudo su -
cd /tmp
wget http://git.io/A3D0 -O install.sh
bash install.sh "/dev/sda"
```
**NOTE**: This needs to be run with /bin/bash, not /bin/sh, which is ash.

After you've made a USB stick and booted from it, you can download and run the `install.sh` again and install to `/dev/mmcblk0` (the eMMC) for a much nicer/faster Arch experience.

Log in as the *root* user which was created during the install process.  Then, select which wifi network to join:
```
wifi-menu mlan0
```

Then, download and run the install script, but this time on the internal storage:
```
pacman -Syy wget
wget http://git.io/A3D0 -O install.sh
bash install.sh "/dev/mmcblk0"
```
Regarding the modification of the PKGBUILD for `trousers`:

This is the only package you need to modify. When prompted, press `y` to edit, open in `nano` or your preferred text editor, find the line that reads:

```
arch=('i686' 'x86_64')
```

and replace it with

```
arch=('armv7h')
```

You can then build and install `trousers` and `vboot-utils` with no problem.


## Post-install

I've included a [`post-install.sh`](https://raw.githubusercontent.com/omgmog/archarm-usb-hp-chromebook-11/master/post-install.sh), which you can use to setup the final bits after you've booted your Arch USB stick.

```
cd /
sh post-install.sh
```

This will install the following packages:

```
mate mate-extra xorg-server xorg-xinit xorg-server-utils xterm alsa-utils xf86-video-armsoc-chromium xf86-input-synaptics lightdm lightdm-gtk2-greeter
```
