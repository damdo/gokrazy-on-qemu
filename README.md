## ARCHIVED
This repo is archived in favour of the official vm funcionality included in gokrazy's `gok vm`. For details see: https://github.com/gokrazy/tools/commit/b8ffcd451e68c9554b766b0f57a6de4256130508

## gokrazy-on-qemu

A qemu setup to develop for the [gokrazy](https://gokrazy.org) ecosystem.

To set this up, you can choose:
- to run this directly on your machine. To do so make sure your machine has all the following requirements
  - `qemu` >= `7.1.0`
  - `go` >= `1.18`
  - `zip`
  - `sed`

  You can then follow along with the other steps, but skip the `ENVIRONMENT` section.
- to run this within a dedicated Ubuntu VM (VirtualBox) that can be created for you by Vagrant.
  - just follow along all the steps.

```bash
##### 1) OBTAIN
# Obtain this repo by:
git clone https://github.com/damdo/gokrazy-on-qemu
cd gokrazy-on-qemu/

##### 2) ENVIRONMENT
# Tweak the Vagrantfile to your specific environment
# e.g. update the networking bits to match your network card
# or just ignore the vagrant bits if you have an environment
# already properly setup for qemu.

# Provision the vm.
vagrant up

# SSH into the vm.
vagrant ssh
cd gokrazy-on-qemu/

##### 3) BUILD and RUN
# Build the drive.img the first time.
# Available values for 'GOARCH' are: amd64, arm64
# Available values for 'GOOS' are: linux, darwin
GOARCH=<arch> GOOS=<os> ./build.sh

# Run the emulation machine.
# Available values for 'MACHINE' are: amd64, arm64, raspi3b
sudo MACHINE=<machine> ./run.sh

# The following updates can be Over the Air.
# First you change the components to be included in the gokrazy build
# by modifiying the array list in the top section of build.sh and then,
# setting OUTPUT=ota will automatically
# perform an over-the-network (via http/https) update to a running gokrazy instance.
# The address for the ota can be tweaked by setting the SHOULDUPDATE_CONTENT env var.
GOARCH=<arch> GOOS=linux OUTPUT=ota SHOULDUPDATE_CONTENT="http://gokrazy:$(cat $HOME/.config/gokrazy/http-password.txt)@<IP:Port>/" ./build.sh
# or for macOS/darwin
GOARCH=<arch> GOOS=darwin OUTPUT=ota SHOULDUPDATE_CONTENT="http://gokrazy:$(cat $HOME/Library/Application\ Support/gokrazy/http-password.txt)@<IP:Port>/" ./build.sh

# NOTE: if (and only if) you are using Vagrant as the base of your setup
# use this value
# SHOULDUPDATE_CONTENT:="http://gokrazy:$(cat $HOME/.config/gokrazy/http-password.txt)@127.0.0.1:8080/"
# which takes into account for the local ip and the port forwarding happening on that setup.

# alternatively
# Setting OUTPUT=single allows to force a rebuild of the img file
# (you will then need to ./run.sh again to load it afresh).
GOARCH=<arch> GOOS=<os> OUTPUT=single ./build.sh

# alternatively
# setting OUTPUT=multi will output 3 separate files for:
# boot: boot.img
# root: root.squashfs
# mbr: mbr.img
# This is useful for special purposes when you need
# separated files for each partition.
GOARCH=<arch> GOOS=<os> OUTPUT=multi ./build.sh
```
