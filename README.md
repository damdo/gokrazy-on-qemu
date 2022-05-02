## gokrazy-on-qemu
A qemu emulator to develop for the https://gokrazy.org environment

```bash
vagrant up && vagrant ssh

# once within the vm shell

cd gokrazy-on-qemu/

# build the drive.img the first time
# available values for 'GOARCH' are: amd64, arm64
GOARCH=<arch> ./build.sh

# run the emulation machine
# available values for 'MACHINE' are: amd64, arm64, arm64-auto, raspi3b
MACHINE=<machine> ./run.sh

# for the following updates re-running the build will automatically
# trigger an over-the-network (via http/https) update
GOARCH=<arch> ./build.sh
```

#### TODO
- [ ] multi platform compatible
