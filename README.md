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
# Trigger the build will automatically
# perform an over-the-network (via http/https) update to the gokrazy instance.
GOARCH=<arch> ./build.sh
```
