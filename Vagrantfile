Vagrant.configure("2") do |config|
  config.vm.box = "centos-6.5"
  config.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.1/centos65-x86_64-20131205.box"

  config.vm.hostname = "vagrant-cloudstack-simulator"
  config.vm.network "private_network", ip: "33.33.33.101"

  config.vm.provider "virtualbox" do |vbox|
    vbox.memory = 2048
  end

  config.vm.provision :shell, path: "bootstrap.sh"
end
