#!/usr/bin/env bash

qemu-system-x86_64 \
  -name gokrazy-amd64 \
  -m 4096 \
  -smp $(nproc) \
  -usb \
  -nographic \
  -serial mon:stdio \
  -boot order=d \
  -drive file=drive.img,format=raw \
  -netdev user,id=mynet0,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22 \
  -device e1000,netdev=mynet0
