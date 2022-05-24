Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.synced_folder "./", "/home/vagrant/gokrazy-on-qemu"
  config.vm.provision :docker
  config.vm.provision "shell",
    inline: $provision,
    env: {
      "GO_VERSION"=>"1.18",
      "KIND_VERSION"=>"v0.12.0",
      "KUBECTL_VERSION"=>"v1.23.4",
    }
  config.vm.provider "virtualbox" do |v|
    v.memory = 20480
    v.cpus = 8
  end
  config.vm.network "public_network", bridge: "en0: Wi-Fi (Wireless)"
end

$provision = <<SCRIPT
############### install dependencies
# setup user
usermod -a -G docker $USER

# build tools
apt update -yq && apt install -yq curl zip

# install go
snap install go --channel="${GO_VERSION}"/stable --classic

# install kind
GOBIN=$(pwd)/ go install sigs.k8s.io/kind@"${KIND_VERSION}"
  chmod +x ./kind && \
  mv kind /usr/bin/

# install kubectl
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
  chmod +x ./kubectl && \
  mv kubectl /usr/bin/
echo "alias k=kubectl" >> /home/vagrant/.profile

# install qemu
sudo sed -i~orig -e 's/# deb-src/deb-src/' /etc/apt/sources.list
sudo apt-get update
sudo apt-get -yq build-dep qemu
sudo apt-get -yq install itstool qemu-efi-aarch64
cd /tmp && \
  curl -SLO https://download.qemu.org/qemu-5.2.0.tar.xz && \
  tar -xf qemu-5.2.0.tar.xz && \
  cd qemu-5.2.0 && \
  ./configure && \
  make -j 8 && \
  sudo make install

SCRIPT
