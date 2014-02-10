Arch ARM USB installer for the HP Chromebook 11
============================


A write-up of the process can be found on [my blog](http://blog.omgmog.net/post/installing-arch-linux-arm-on-the-hp-chromebook-11/).


## Derived from the following:

- [https://gist.github.com/cochrandv/8403647](https://gist.github.com/cochrandv/8403647)
- [http://archlinuxarm.org/platforms/armv7/samsung/samsung-chromebook](http://archlinuxarm.org/platforms/armv7/samsung/samsung-chromebook)

## Prerequisits:

- Enabled developer mode
- Enabled booting from USB devices

## To use this script:

```
sh install.sh "/dev/sda"
```

I've included a [`post-install.sh`](https://raw2.github.com/omgmog/archarm-usb-hp-chromebook-11/master/post-install.sh), which you can use to setup the final bits after you've booted your Arch USB stick.

```
pacman -S wget
wget https://raw2.github.com/omgmog/archarm-usb-hp-chromebook-11/master/post-install.sh
sh post-install.sh
```

## Using Chromium as root
Can't be bothered to make a new user, and want to run everything as `root`? Well Chromium doesn't like that, but we can fix this. First, install `hexedit` and `chromium`:

```
pacman -S hexedit chromium
```

Then simply do the following:

```
hexedit /usr/lib/chromium/chromium
```

- Press `tab`
- Press `ctrl` + `s`, type `geteuid` and change the match to `getppid`
- Press `ctrl` + `x`, then `y`

Now Chromium will run as root.
