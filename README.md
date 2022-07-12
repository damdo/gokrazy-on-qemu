## gokrazy-on-qemu
A qemu setup to develop for the [gokrazy](https://gokrazy.org) ecosystem.

```bash
# Obtain this repo.
git clone https://github.com/damdo/gokrazy-on-qemu
cd gokrazy-on-qemu/

# Tweak the Vagrantfile to your specific environment
# e.g. update the networking bits to match your network card
# or just ignore the vagrant bits if you have an environment
# already properly setup for qemu.

# Provision the vm.
vagrant up

# SSH into the vm.
vagrant ssh
cd gokrazy-on-qemu/

# Build the drive.img the first time.
# Available values for 'GOARCH' are: amd64, arm64
GOARCH=<arch> ./build.sh

# Run the emulation machine.
# Available values for 'MACHINE' are: amd64, arm64, raspi3b
MACHINE=<machine> ./run.sh

# For the following updates, change the components to be included in the gokrazy build
# by modifiying the array list in the top section of build.sh.
# Setting OUTPUT=ota will automatically
# perform an over-the-network (via http/https) update to a running gokrazy instance.
GOARCH=<arch> OUTPUT=ota ./build.sh
# Optionally the address for the ota can be tweaked by setting the SHOULDUPDATE_CONTENT env var.
# GOARCH=<arch> SHOULDUPDATE_CONTENT="http://gokrazy:$(cat $HOME/.config/gokrazy/http-password.txt)@127.0.0.1:8080/" OUTPUT=ota ./build.sh

# alternatively
# Setting OUTPUT=single allows to force a rebuild of the img file.
GOARCH=<arch> OUTPUT=single ./build.sh

# alternatively
# Setting OUTPUT=multi will output 3 separate files for:
# boot: boot.img
# root: root.squashfs
# mbr: mbr.img
GOARCH=<arch> OUTPUT=multi ./build.sh
```
