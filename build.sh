#!/usr/bin/env bash

# ---------------------------
# VARS
# ---------------------------

# output chooses whether to output a single drive img or multiple partition imgs
# single: one drive.img
# multi: boot: boot.img, root: root.squashfs, mbr: mbr.img
# ota: forces over the air (http) update
# default is: single
output="${OUTPUT:=single}"
gokr_packer_version="latest"
gokr_packer_base="github.com/gokrazy/tools/cmd/gokr-packer"
gokrazy_version="latest"
gokrazy_base="github.com/gokrazy/gokrazy"
hostname="gokrazy"
components=(
  github.com/gokrazy/gokrazy@latest
  github.com/gokrazy/breakglass@latest
  github.com/gokrazy/serial-busybox@latest
  github.com/prometheus/node_exporter@5ea0a93
  github.com/gokrazy/timestamps@latest
)
os="${GOOS:=linux}"
arch="${GOARCH:=amd64}"
case $arch in
  arm64)
    kernel_package="github.com/gokrazy/kernel@latest"
    firmware_package="github.com/gokrazy/firmware@latest"
    serial_console="ttyAMA0,115200"
    ;;
  amd64)
    kernel_package="github.com/rtr7/kernel@latest"
    firmware_package="github.com/rtr7/kernel@latest"
    serial_console="ttyS0,115200"
    ;;
  *)
    echo -n "unsupported arch ${arch}"
    exit
    ;;
esac

# ---------------------------
# GOKRAZY SETUP
# ---------------------------
echo "gokrazy ensuring version: '${gokr_packer_version}'"
GOBIN=$(pwd) GOARCH=amd64 GOOS=$os go get "${gokrazy_base}@${gokrazy_version}"

# ---------------------------
# GOKR-PACKER SETUP
# ---------------------------
version="$(GOBIN=$(pwd) GOARCH=amd64 go version -m ./gokr-packer 2>/dev/null | grep mod | sed 's/[[:space:]]/,/g' | cut -d ',' -f4)"
if [[ ${gokr_packer_version} != ${version} ]]; then
  echo "gokr-packer version '${version}' is not the desired one '${gokr_packer_version}'"
  echo "fetching '${gokr_packer_version}'.."
  GOBIN=$(pwd) GOARCH=amd64 GOOS=$os go install "${gokr_packer_base}@${gokr_packer_version}"
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

if [[ "$firmware_package" == *"@"* ]]; then
  go get $firmware_package
fi

if [[ "$kernel_package" == *"@"* ]]; then
  go get $kernel_package
fi

unversioned_firmware_package="$(echo "$firmware_package" | sed 's/@.*//g')"
unversioned_kernel_package="$(echo "$kernel_package" | sed 's/@.*//g')"

# ---------------------------
# SHOULD UPDATE?
# ---------------------------
shouldupdate_content="${SHOULDUPDATE_CONTENT:="http://gokrazy:$(cat $HOME/.config/gokrazy/http-password.txt)@127.0.0.1:8080/"}"

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
elif [[ "$output" == "device" ]]; then
  args+=(\
   -overwrite=/dev/disk2
  )
elif  [[ "$output" == "multi" ]]; then
  args+=(\
   -overwrite_boot=boot.img
   -overwrite_root=root.squashfs
   -overwrite_mbr=mbr.img
  )
elif  [[ "$output" == "ota" ]]; then
  shouldupdate=$shouldupdate_content
fi

args+=(
 -hostname="${hostname}"
 -kernel_package="${unversioned_kernel_package}"
 -firmware_package="${unversioned_firmware_package}"
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
