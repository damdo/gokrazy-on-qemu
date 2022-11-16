Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.synced_folder "./", "/home/vagrant/gokrazy-on-qemu"
  config.vm.provision :docker
  config.vm.provision "shell",
    inline: $provision,
    env: {
      "GO_VERSION"=>"1.19",
    }
  config.vm.provider "virtualbox" do |v|
    v.memory = 20480
    v.cpus = 8
  end
  #config.vm.network "public_network", bridge: "en0: Wi-Fi (Wireless)"
  #config.vm.network "public_network", bridge: "en7: Thunderbolt Ethernet"
  config.vm.network "public_network", bridge: "en7: USB 10/100/1000 LAN"
end

$provision = <<SCRIPT
############### install dependencies
# setup user
usermod -a -G docker $USER

# build tools
apt update -yq && apt install -yq curl zip

# install go
curl -SsLO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
&& tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" \
&& rm "go${GO_VERSION}.linux-amd64.tar.gz"
LINE='PATH=$PATH:/usr/local/go/bin'
FILE='/etc/profile'
grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
source /etc/profile

# install qemu
sudo sed -i~orig -e 's/# deb-src/deb-src/' /etc/apt/sources.list
sudo apt-get update
sudo apt-get -yq build-dep qemu
sudo apt-get -yq install itstool qemu-efi-aarch64
cd /tmp && \
  curl -SLO https://download.qemu.org/qemu-7.1.0.tar.xz && \
  tar -xf qemu-7.1.0.tar.xz && \
  cd qemu-7.1.0 && \
  ./configure && \
  make -j 8 && \
  sudo make install

SCRIPT
