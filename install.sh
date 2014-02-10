#!/bin/bash

log() {
    printf "\n\033[32m$*\033[00m\n"
    read -p "Press [enter] to continue." KEY
}

TARGET=${1:-"/dev/sda"}
OSHOST="http://archlinuxarm.org/os/"
OSFILE="ArchLinuxARM-chromebook-latest.tar.gz"
UBOOTHOST="https://github.com/jquagga/nv_uboot-spring/raw/master/"
UBOOTFILE="nv_uboot-spring.kpart.gz"

log "Creating volumes on ${TARGET}"
umount ${TARGET}*
parted ${TARGET} mklabel gpt
cgpt create -z ${TARGET}
cgpt create ${TARGET}
cgpt add -i 1 -t kernel -b 8192 -s 32768 -l U-Boot -S 1 -T 5 -P 10 ${TARGET}
cgpt add -i 2 -t data -b 40960 -s 32768 -l Kernel ${TARGET}
cgpt add -i 12 -t data -b 73728 -s 32768 -l Script ${TARGET}
PARTSIZE=`cgpt show ${TARGET} | grep 'Sec GPT table' | egrep -o '[0-9]+' | head -n 1`
cgpt add -i 3 -t data -b 106496 -s `expr ${PARTSIZE} - 106496` -l Root ${TARGET}
partprobe ${TARGET}
mkfs.ext2 ${TARGET}2
mkfs.ext4 ${TARGET}3
mkfs.vfat -F 16 ${TARGET}12

cd /tmp

if [ ! -f "${OSFILE}" ]; then
    log "Downloading ${OSFILE}"
    wget ${OSHOST}${OSFILE}
else
    log "Looks like you already have ${OSFILE}"
fi

log "Installing Arch to ${TARGET} (this will take a moment...)"
mkdir -p root
mount ${TARGET}3 root
tar -xf ${OSFILE} -C root

mkdir -p mnt
mount ${TARGET}2 mnt
cp root/boot/vmlinux.uimg mnt
umount mnt

mount ${TARGET}12 mnt
mkdir -p mnt/u-boot
cp root/boot/boot.scr.uimg mnt/u-boot
umount mnt

if [ ! -f "${UBOOTFILE}" ]; then
    log "Downloading ${UBOOTFILE}"
    wget ${UBOOTHOST}${UBOOTFILE}
else
    log "Looks like you already have ${UBOOTFILE}"
fi
gunzip -f ${UBOOTFILE}
log "Writing uboot to ${TARGET}1 (this will take a moment...)"
dd if=nv_uboot-spring.kpart of=${TARGET}1
umount root
sync

log "Creating and entering Arch chroot."
mount ${TARGET}3 /tmp/root
cp /etc/resolv.conf /tmp/root/etc/resolv.conf
mount -o bind /dev /tmp/root/dev
mount -t devpts none /tmp/root/dev/pts
mount -t proc proc /tmp/root/proc
mount -t sysfs sys /tmp/root/sys
chroot /tmp/root /bin/bash
