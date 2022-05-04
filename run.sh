#!/usr/bin/env bash

arch="${MACHINE:=amd64}"
case $arch in
  # arm64 emulator with kernel auto loading
  # it uses the QEMU_EFI bios to load /EFI/BOOT/BOOTAA64.efi which loads grub.efi,
  # which through the config provided via grub.cfg, loads the kernel and passes params to it
  #
  # IMPORTANT: to work it requires the drive.img to contain in its first partition:
  # - /EFI/BOOT/BOOTAA64.efi
  # - /EFI/BOOT/grub.efi
  # - /EFI/BOOT/grub.cfg
  arm64-auto)
    qemu-system-aarch64 \
      -name gokrazy-arm64 \
      -m 3G \
      -smp $(nproc) \
      -M virt,highmem=off \
      -cpu cortex-a72 \
      -nographic \
      -netdev user,id=net0,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22 \
      -device e1000,netdev=net0 \
      -drive file=drive.img,format=raw \
      -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd
    ;;

  # arm64 emulator with manual kernel loading
  # requires kernel (./vmlinuz) extraction from the drive.img,
  # to be used as an arg (with -kernel and -append)
  # to instruct the vm on how to load the kernel
  arm64)
    # Extract the kernel (vmlinuz) from the drive.img first
    ./extract_kernel.sh
    qemu-system-aarch64 \
      -name gokrazy-arm64 \
      -m 3G \
      -smp $(nproc) \
      -M virt,highmem=off \
      -cpu cortex-a72 \
      -nographic \
      -netdev user,id=net0,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22 \
      -device e1000,netdev=net0 \
      -drive file=drive.img,format=raw \
      -kernel vmlinuz \
      -append "console=tty1 console=ttyAMA0,115200 root=PARTUUID=60c24cc1-f3f9-427a-8199-2e18c40c0001/PARTNROFF=1 init=/gokrazy/init rootwait panic=10 oops=panic"
    ;;

  # raspi3b emulator with manual kernel loading
  # requires kernel (./vmlinuz) and dtb file extraction from the drive.img,
  # to be used as an arg (with -dtb, -kernel and -append)
  # to instruct the vm on how to load the kernel
  raspi3b)
    # Only works with qemu === v5.2.0
    # because for lower versions networking is missing.
    # It was introduced in qemu v5.2.0 via usb networking (-device usb-net), but it is very very slow at the point that gokrazy network updates fail.
    # For qemu versions >= v6.0.0, the /gokrazy/init process crashes early at gokrazy.Boot(). To be investigated.
    qemu_version="$(qemu-system-aarch64 --version | sed -nr 's/^.*version\s([.0-9]*).*$/\1/p')"
    if [[ "$qemu_version" != "5.2.0" ]]; then
      echo "error: incompatible qemu-system-aarch64 version: $qemu_version. gokrazy on raspi3b can only run on 5.2.0"
      exit 1;
    fi

    # Extract the kernel (vmlinuz) and the dtb file from the drive.img first
    ./extract_kernel.sh
    qemu-system-aarch64 \
      	-name gokrazy-arm64-raspi3b \
        -m 1024 \
        -no-reboot \
        -M raspi3b \
        -append "console=tty1 console=ttyAMA0,115200 dwc_otg.fiq_fsm_enable=0 root=/dev/mmcblk0p2 init=/gokrazy/init rootwait panic=10 oops=panic" \
        -dtb ./bcm2710-rpi-3-b-plus.dtb \
        -nographic \
        -serial mon:stdio \
        -drive file=drive.img,format=raw \
        -kernel vmlinuz \
        -netdev user,id=net0,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22 \
        -device usb-net,netdev=net0
    ;;

  # amd64 emulator with kernel auto loading
  amd64)
    qemu-system-x86_64 \
      -name gokrazy-amd64 \
      -m 3G \
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
