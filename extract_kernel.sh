#!/usr/bin/env bash

sudo umount /mnt/tmp
sudo mkdir -p /mnt/tmp
s1=$(fdisk -l drive.img | grep drive.img1 | cut -d" " -f5)
s2=$(fdisk -l drive.img | grep drive.img1 | cut -d" " -f7)
echo "if: $s1"
echo "of: $s2"
sudo dd if=drive.img of=kernel.img skip="$s1" count="$s2"
sudo mount -o loop kernel.img /mnt/tmp
sudo qemu-img resize drive.img 2G
cp /mnt/tmp/vmlinuz .
cp /mnt/tmp/bcm2710-rpi-3-b-plus.dtb .
