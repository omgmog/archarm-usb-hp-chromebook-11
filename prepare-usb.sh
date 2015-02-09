#!/usr/bin/env bash

check_bin(){

hash "$1"  2>/dev/null
if [ "$?" -gt 0 ]; then
 echo ": pre-check failed.. please install $1"
 exit 1
fi
}

for i in parted mkfs.vfat mkfs.ext4 cgpt grep egrep partprobe ; do
    check_bin "$i"
done

warn(){
cat <<EOF
This Script will prepare a USB device for Use with the script.
It should be run on a normal linux install (not chromeos) with the cgpt package
it should also, of course, be run as root
Please Input the disk you wish to prepare in the format /dev/sdX . X being the disks letter

Not sure which disk to use? "fdisk -l" is always a decent starting place.. ALWAYS DOUBLE CHECK!

WARNING : CHOOSING THE INCORRECT DISK COULD CAUSE DATA LOSS. DO NOT DO THIS UNLESS YOU KNOW WHAT YOU ARE DOING
If for any reason you wish to quit this script, press Ctrl + C now.

EOF
}


getdev(){
DEVICE=
while [ X"$DEVICE" == X ]; do
    echo ": Please enter the device you want to prepare EG: /dev/sdX"
    read DEVICE
done
}

warn
getdev

while [ ! -b "$DEVICE" ]; do
  echo ": error.. $DEVICE is not a block device"
  exit 1
done

P1="${DEVICE}1"
P2="${DEVICE}2"
P3="${DEVICE}3"
P12="${DEVICE}12"
echo ": Creating volumes on ${DEVICE}"
for i in ${DEVICE}* ; do
  echo ": umount -f $i"
  umount -f "$i" 2>/dev/null
done

echo ": creating gpt label on $DEVICE"
parted ${DEVICE} mklabel gpt
echo ": prepping cgpt 'stuff'"
cgpt create -z ${DEVICE}
cgpt create ${DEVICE}
cgpt add -i 1 -t kernel -b 8192 -s 32768 -l U-Boot -S 1 -T 5 -P 10 ${DEVICE}
cgpt add -i 2 -t data -b 40960 -s 32768 -l Kernel ${DEVICE}
cgpt add -i 12 -t data -b 73728 -s 32768 -l Script ${DEVICE}
PARTSIZE=`cgpt show ${DEVICE} | grep 'Sec GPT table' | egrep -o '[0-9]+' | head -n 1`
cgpt add -i 3 -t data -b 106496 -s `expr ${PARTSIZE} - 106496` -l Root ${DEVICE}
sleep 0.1
echo ": re-probing device"
partprobe ${DEVICE}
echo ": formatting $P2"
mkfs.ext2 -m 0 "$P2"
echo ": formatting $P3"
mkfs.ext4 -m 0 "$P3"
echo ": formatting $P12"
mkfs.vfat -F 16 "$P12"
echo ": completed.. may the force be with you"
