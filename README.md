## gokrazy-emulator
A qemu emulator to develop for the https://gokrazy.org environment

```bash
vagrant up && vagrant ssh

# once within the vm shell

cd gokrazy-emulator/

# build the drive.img the first time
./build.sh

# run the emulation vm
./run.sh

# for the following updates re-running the build will automatically
# trigger an over-the-network (via http/https) update
./build.sh
```

#### TODO
- [ ] multi platform compatible
