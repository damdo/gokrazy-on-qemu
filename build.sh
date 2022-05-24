#!/usr/bin/env bash

# ---------------------------
# VARS
# ---------------------------

# output chooses whether to output a single drive img or multiple partition imgs
# single: one drive.img
# multi: boot: boot.img, root: root.squashfs, mbr: mbr.img
# default is: single
output="${OUTPUT:=single}"
gokr_packer_version="v0.0.0-20220507152425-0d3aef012e03"
gokr_packer_base="github.com/gokrazy/tools/cmd/gokr-packer"
hostname="gokrazy"
components=(
  github.com/gokrazy/breakglass
  github.com/gokrazy/serial-busybox
  github.com/prometheus/node_exporter@5ea0a93
  github.com/gokrazy/timestamps
)
arch="${GOARCH:=amd64}"
case $arch in
  arm64)
    kernel_package="github.com/gokrazy/kernel"
    firmware_package="github.com/gokrazy/firmware"
    serial_console="ttyAMA0,115200"
    ;;
  amd64)
    kernel_package="github.com/rtr7/kernel"
    firmware_package="github.com/rtr7/kernel"
    serial_console="ttyS0,115200"
    ;;
  *)
    echo -n "unsupported arch ${arch}"
    exit
    ;;
esac

# ---------------------------
# GOKR-PACKER SETUP
# ---------------------------
version="$(GOBIN=$(pwd) GOARCH=amd64 go version -m ./gokr-packer 2>/dev/null | grep mod | sed 's/[[:space:]]/,/g' | cut -d ',' -f4)"
if [[ ${gokr_packer_version} != ${version} ]]; then
  echo "gokr-packer version '${version}' is not the desired one '${gokr_packer_version}'"
  echo "fetching '${gokr_packer_version}'.."
  GOBIN=$(pwd) GOARCH=amd64 go install "${gokr_packer_base}@${gokr_packer_version}"
fi

# ---------------------------
# EXTRAFILES/FLAGS/ENV VARS
# ---------------------------

# breakglass
mkdir -p extrafiles/github.com/gokrazy/breakglass/etc/

if [ ! -f "$HOME/.ssh/id_rsa" ]; then
< /dev/zero ssh-keygen -b 2048 -t rsa -q -N ""
fi
cat ~/.ssh/id_*.pub > extrafiles/github.com/gokrazy/breakglass/etc/breakglass.authorized_keys
mkdir -p flags/github.com/gokrazy/breakglass/
echo '-authorized_keys=/etc/breakglass.authorized_keys' > flags/github.com/gokrazy/breakglass/flags.txt

# ---------------------------
# PIN COMPONENTS
# ---------------------------
unversioned_components=()
for i in "${components[@]}"
do
  unversioned_components+=($(echo "$i" | sed 's/@.*//g'))
  if [[ "$i" == *"@"* ]]; then
    go get $i
  fi
done

# ---------------------------
# SHOULD UPDATE?
# ---------------------------
# if a qemu machine with `-name gokrazy` is already running, then update and write to file
# else just write to file.
if [[ "$(ps -ef | grep qemu-system- | grep gokrazy | wc -l)" -eq 1 ]]; then
  if [[ "$output" == "multi" ]]; then
    echo "ERROR: would update OTA the existing gokrazy installation but can't because 'multi' mode is set, should be 'single'."
  fi
  shouldupdate="http://gokrazy:$(cat ~/.config/gokrazy/http-password.txt)@127.0.0.1:8080/"
else
  shouldupdate=""
fi

# ---------------------------
# GOKR-PACKER RUN
# ---------------------------
echo "building grokrazy img(s) in '$output' mode"

# arguments list
args=()

# Build up conditional arguments
if [[ "$output" == "single" ]]; then
  args+=(\
   -overwrite=drive.img
  )
elif  [[ "$output" == "multi" ]]; then
  args+=(\
   -overwrite_boot=boot.img
   -overwrite_root=root.squashfs
   -overwrite_mbr=mbr.img
  )
fi

args+=(
 -hostname="${hostname}"
 -kernel_package="${kernel_package}"
 -firmware_package="${firmware_package}"
 -target_storage_bytes=2147483648
 -serial_console="${serial_console}"
 -update="${shouldupdate}"
 ${unversioned_components[@]}
)

GOOS=linux GOARCH="${arch}" GOBIN=$(pwd) ./gokr-packer "${args[@]}"

# ---------------------------
# COMPRESS
# ---------------------------
if [[ "$output" == "multi" ]]; then
  zip -r drive.zip mbr.img boot.img root.squashfs
fi

# ---------------------------
# CLEANUP
# ---------------------------
# cleanup generated gokrazy artifacts
rm -rf ./extrafiles ./flags ./env ./buildflags
if [[ "$output" == "multi" ]]; then
  rm boot.img root.squashfs mbr.img
fi

# ---------------------------
# OUTPUT
# ---------------------------
echo ""
echo "======"
echo "OUTPUT"
echo "======"
if [[ "$output" == "single" ]]; then
  echo "'$output' mode: drive.img has been generated."
elif  [[ "$output" == "multi" ]]; then
  echo "'$output' mode: drive.zip has been generated."
fi
