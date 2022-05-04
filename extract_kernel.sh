#!/usr/bin/env bash

echo " -> extracting kernel.."

# prepare for mounting
echo "cleanup"
sudo umount /mnt/tmp
sudo rm -rf /mnt/tmp
sudo mkdir -p /mnt/tmp
sudo rm -f drivep1.img

# find the starting and ending sector of the first partition
# the one for gokrazy where the kernel and the dtbs are
s1=$(fdisk -l drive.img | grep drive.img1 | cut -d" " -f5)
s2=$(fdisk -l drive.img | grep drive.img1 | cut -d" " -f7)
echo "if: $s1"
echo "of: $s2"

# extract the first partition
echo "extract first partition"
sudo dd if=drive.img of=drivep1.img skip="$s1" count="$s2"

# loop mount the first partition
echo "loop mount first partition"
sudo mount -o loop drivep1.img /mnt/tmp

# copy the kernel and the dtb in the local folder
echo "copy files locally"
sudo cp -f /mnt/tmp/vmlinuz .
sudo cp -f /mnt/tmp/bcm2710-rpi-3-b-plus.dtb .

echo "<- done extracting kernel"
