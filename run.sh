#!/usr/bin/env bash

arch="${MACHINE:=amd64}"
case $arch in
  arm64)
    qemu-system-aarch64 \
      -name gokrazy-arm64 \
      -m 4G \
      -smp $(nproc) \
      -M virt,highmem=off \
      -cpu cortex-a72 \
      -nographic \
      -drive if=none,file=drive.img,format=raw,id=mydisk \
      -device ich9-ahci,id=ahci -device ide-hd,drive=mydisk,bus=ahci.0 \
      -netdev user,id=net0,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22 \
      -device e1000,netdev=net0 \
      -kernel vmlinuz \
      -append "console=tty1 console=ttyAMA0,115200 dwc_otg.fiq_fsm_enable=0 root=/dev/sda2 rw init=/gokrazy/init rootwait panic=10 oops=panic"
    ;;
  raspi3b)
    # only works with qemu === v5.2.0
    # because for lower versions the usb networking is missing
    # and because for higher versions 6.0+, the /gokrazy/init process crashes early at gokrazy.Boot()
    qemu-system-aarch64 \
        -m 1024 \
        -no-reboot \
        -M raspi3b \
        -append "console=tty1 console=ttyAMA0,115200 dwc_otg.fiq_fsm_enable=0 root=/dev/mmcblk0p2 init=/gokrazy/init rootwait panic=10 oops=panic" \
        -dtb ./bcm2710-rpi-3-b-plus.dtb \
        -nographic \
        -serial mon:stdio \
        -drive file=drive.img \
        -kernel vmlinuz \
        -device usb-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22 # introduced in qemu v5.2.0
    ;;
  amd64)
    qemu-system-x86_64 \
      -name gokrazy-amd64 \
      -m 4G \
      -smp $(nproc) \
      -usb \
      -nographic \
      -serial mon:stdio \
      -boot order=d \
      -drive file=drive.img,format=raw \
      -netdev user,id=net0,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22 \
      -device e1000,netdev=net0
    ;;
  *)
    echo -n "unsupported arch ${arch}"
    exit
    ;;
esac
