#!/bin/bash

log() {
    printf "\n\033[32m$*\033[00m\n"
    read -p "Press [enter] to continue." KEY
}

EMMC="/dev/mmcblk0"
DEFAULT_USB="/dev/sda"
DEVICE=${1:-$DEFAULT_USB}

if [ "$DEVICE" = "$EMMC" ]; then
    P1="${DEVICE}p1"
    P2="${DEVICE}p2"
    P3="${DEVICE}p3"
    P12="${DEVICE}p12"
else
    P1="${DEVICE}1"
    P2="${DEVICE}2"
    P3="${DEVICE}3"
    P12="${DEVICE}12"
fi

OSHOST="http://archlinuxarm.org/os/"
OSFILE="ArchLinuxARM-chromebook-latest.tar.gz"
BOOTFILE="boot.scr.uimg"
UBOOTHOST="https://github.com/jquagga/nv_uboot-spring/raw/master/"
UBOOTFILE="nv_uboot-spring.kpart.gz"

if [ $DEVICE = $EMMC ]; then
    # for eMMC we need to get some things before we can partition
    echo -e "\n[archlinuxfr]\nSigLevel = Never\nServer = http://repo.archlinux.fr/arm\n" >> /etc/pacman.conf
    pacman -Syyu packer devtools-alarm base-devel git libyaml parted dosfstools cgpt parted
    log "When prompted to modify PKGBUILD for trousers, set arch to armv7h"
    packer -S trousers vboot-utils
fi

log "Creating volumes on ${DEVICE}"
umount ${DEVICE}*
parted ${DEVICE} mklabel gpt
cgpt create -z ${DEVICE}
cgpt create ${DEVICE}
cgpt add -i 1 -t kernel -b 8192 -s 32768 -l U-Boot -S 1 -T 5 -P 10 ${DEVICE}
cgpt add -i 2 -t data -b 40960 -s 32768 -l Kernel ${DEVICE}
cgpt add -i 12 -t data -b 73728 -s 32768 -l Script ${DEVICE}
PARTSIZE=`cgpt show ${DEVICE} | grep 'Sec GPT table' | egrep -o '[0-9]+' | head -n 1`
cgpt add -i 3 -t data -b 106496 -s `expr ${PARTSIZE} - 106496` -l Root ${DEVICE}
partprobe ${DEVICE}
mkfs.ext2 $P2
mkfs.ext4 $P3
mkfs.vfat -F 16 $P12

cd /tmp

if [ ! -f "${OSFILE}" ]; then
    log "Downloading ${OSFILE}"
    wget ${OSHOST}${OSFILE}
else
    log "Looks like you already have ${OSFILE}"
fi

log "Installing Arch to ${P3} (this will take a moment...)"
mkdir -p root

mount $P3 root
tar -xf ${OSFILE} -C root
log "Ensuring arch rootfs is correctly mounted"
mount -o remount,exec root/
log "Copying resolv.conf from your chromebook for networking"
rm root/etc/resolv.conf
cp /etc/resolv.conf root/etc/resolv.conf
log "mounting proc,sys and dev for chroot"
mount -t proc proc root/proc/
mount --rbind /sys root/sys/
mount --rbind /dev root/dev/
log "downloading old version of systemd"
wget https://www.dropbox.com/s/ajfrn1gwtl8b3ap/systemd-212-3-armv7h.pkg.tar.xz?dl=0 --output-document=root/systemd-212-3-armv7h.pkg.tar.xz
log "creating systemd fix script"
echo "#!/bin/bash" >> root/chrootscript.sh
echo "pacman -Ud /systemd-212-3-armv7h.pkg.tar.xz" >> root/chrootscript.sh
echo "echo 'IgnorePkg = systemd'>>etc/pacman.conf" >> root/chrootscript.sh
echo "passwd root" >> root/chrootscript.sh
echo "rm chrootscript.sh" >> root/chrootscript.sh
chmod +x root/chrootscript.sh
log "Launching chroot script inside chroot"
chroot root/ /bin/bash -c "/chrootscript.sh"

if [ ! -f "root/boot/${BOOTFILE}" ]; then
    log "Downloading ${BOOTFILE}"
    wget -O "root/boot/${BOOTFILE}" "${OSHOST}exynos/${BOOTFILE}"
else
    log "Looks like we already have boot.scr.uimg"
fi

mkdir -p mnt

mount $P2 mnt
cp root/boot/vmlinux.uimg mnt
umount mnt

mount $P12 mnt
mkdir -p mnt/u-boot
cp root/boot/boot.scr.uimg mnt/u-boot
umount mnt

if [ $DEVICE != $EMMC ]; then
    log "Copying over devkeys (to generate kernel later)"
    mkdir -p /tmp/root/usr/share/vboot/devkeys
    cp -r /usr/share/vboot/devkeys/ /tmp/root/usr/share/vboot/
fi

if [ $DEVICE = $EMMC ]; then
    echo "root=${P3} rootwait rw quiet lsm.module_locking=0" >config.txt

    vbutil_kernel \
    --pack arch-eMMC.kpart \
    --keyblock /usr/share/vboot/devkeys/kernel.keyblock \
    --signprivate /usr/share/vboot/devkeys/kernel_data_key.vbprivk \
    --config config.txt \
    --vmlinuz /boot/vmlinux.uimg \
    --arch arm \
    --version 1

    dd if=arch-eMMC.kpart of=$P1

    sync

    log "All done! Reboot and press ctrl + D to boot Arch"
else
    if [ ! -f "${UBOOTFILE}" ]; then
        log "Downloading ${UBOOTFILE}"
        wget ${UBOOTHOST}${UBOOTFILE}
    else
        log "Looks like you already have ${UBOOTFILE}"
    fi
    gunzip -f ${UBOOTFILE}
    dd if=nv_uboot-spring.kpart of=$P1

    sync

    log "All done! Reboot and press ctrl + U to boot Arch from ${DEVICE}"
fi
