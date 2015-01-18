#!/bin/bash
echo "This Script will prepare a USB device for Use with the script."
echo "It should be run on a normal linux install (not chromeos) with the cgpt package"
echo "it should also, of course, be run as root"
echo "Please Input the disk you wish to prepare in the format /dev/sdX . X being the disks letter"
echo "WARNING : CHOOSING THE INCORRECT DISK COULD CAUSE DATA LOSS. DO NOT DO THIS UNLESS YOU KNOW WHAT YOU ARE DOING"
echo "If for any reason you wish to quit this script, press Ctrl + C now."
read DEVICE
P1="${DEVICE}1"
P2="${DEVICE}2"
P3="${DEVICE}3"
P12="${DEVICE}12"
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
echo "Process Completed."
