#!/usr/bin/env bash

# ---------------------------
# VARS
# ---------------------------
gokr_packer_version="latest"
#gokr_packer_version="v0.0.0-20220430002421-cee0e14dde6c"
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
    ;;
  amd64)
    kernel_package="github.com/rtr7/kernel"
    firmware_package="github.com/rtr7/kernel"
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
  GOBIN=$(pwd) GOARCH=amd64 go install github.com/gokrazy/tools/cmd/gokr-packer@"${gokr_packer_version}"
fi

# ---------------------------
# EXTRAFILES/FLAGS/ENV VARS
# ---------------------------

# breakglass
mkdir -p extrafiles/github.com/gokrazy/breakglass/etc/
< /dev/zero ssh-keygen -b 2048 -t rsa -q -N ""
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
  shouldupdate="http://gokrazy:$(cat ~/.config/gokrazy/http-password.txt)@127.0.0.1:8080/"
else
  shouldupdate=""
fi

# ---------------------------
# GOKR-PACKER RUN
# ---------------------------
GOOS=linux GOARCH="${arch}" GOBIN=$(pwd) ./gokr-packer \
 -hostname="${hostname}" \
 -kernel_package="${kernel_package}" \
 -firmware_package="${firmware_package}" \
 -serial_console="ttyS0,115200" \
 -target_storage_bytes=1258299392 \
 -overwrite=drive.img \
 -update="${shouldupdate}" \
 ${unversioned_components[@]}

# ---------------------------
# CLEANUP
# ---------------------------
# cleanup generated gokrazy artifacts
rm -rf ./extrafiles ./flags ./env ./buildflags
