#!/usr/bin/env bash

# prepare for mounting
sudo umount /mnt/tmp
sudo mkdir -p /mnt/tmp

# find the starting and ending sector of the first partition
# the one for gokrazy where the kernel and the dtbs are
s1=$(fdisk -l drive.img | grep drive.img1 | cut -d" " -f5)
s2=$(fdisk -l drive.img | grep drive.img1 | cut -d" " -f7)
echo "if: $s1"
echo "of: $s2"

# extract the first partition
sudo dd if=drive.img of=drivep1.img skip="$s1" count="$s2"

# loop mount the first partition
sudo mount -o loop drivep1.img /mnt/tmp

# resize drive img to be 2GB precisely
sudo qemu-img resize drive.img 2G

# copy the kernel and the dtb in the local folder
cp -f /mnt/tmp/vmlinuz .
cp -f /mnt/tmp/bcm2710-rpi-3-b-plus.dtb .
