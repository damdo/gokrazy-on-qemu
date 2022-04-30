#!/usr/bin/env bash

arch="${MACHINE:=amd64}"
case $arch in
  arm64)
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
        -device usb-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22

        #-append "rw console=tty1 console=ttyS0,115200 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 init=/gokrazy/init root=/dev/mmcblk0p2 init=/gokrazy/init rootwait panic=10 oops=panic" \
        #working #-append "rw earlyprintk loglevel=8 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 init=/gokrazy/init rootdelay=1" \
        #-append "console=tty1 console=ttyS0,115200 root=PARTUUID=60c24cc1-f3f9-427a-8199-2e18c40c0001/PARTNROFF=1 init=/gokrazy/init rootwait panic=10 oops=panic" \

        #-append "rw earlyprintk=ttyAMA0,115200 loglevel=8 console=ttyAMA0,115200 root=PARTUUID=6c586e13-02 rootfstype=ext4 rootwait" \
    #qemu-system-aarch64 \
    #  -name gokrazy-arm64 \
    #  -m 1024 \
    #  -M raspi3b \
    #  -dtb ./bcm2710-rpi-3-b.dtb \
    #  -kernel vmlinuz \
    #  -append "console=tty1 console=ttyS0,115200 root=PARTUUID=60c24cc1-f3f9-427a-8199-2e18c40c0001/PARTNROFF=1 init=/gokrazy/init rootwait panic=10 oops=panic"
      #-append "rw earlyprintk loglevel=8 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootdelay=1" \
      #-hda 2013-05-25-wheezy-raspbian.img \
      #-net nic \
      #-net user,hostfwd=tcp::5022-:22 \
      #-M raspi3b \
      #-kernel ./vmlinuz \
      #-append "rw earlyprintk loglevel=8 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2" \
      #-m 1024 \
      #-smp 4 \
      #-usb \
      #-nographic -serial null -chardev stdio,id=uart1 -serial chardev:uart1 -monitor none
      #-nographic \
      #-netdev user,id=mynet0,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22 \
      #-device e1000,netdev=mynet0
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
