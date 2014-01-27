# vagrant-cloudstack-simulator

## Prerequisites

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](http://www.vagrantup.com/downloads.html)

## Using the prebuilt box

Create a Vagrantfile:

```rb
Vagrant.configure("2") do |config|
  config.vm.box = "cloudstack-simulator"
  config.vm.box_url = "https://dl.dropboxusercontent.com/u/4153969/PromptWorks/cloudstack-simulator.box"

  config.vm.network "private_network", ip: "10.0.123.101"

  config.vm.provider "virtualbox" do |vbox|
    vbox.memory = 2048
  end
end
```

and start the box:

```
$ vagrant up
```

## Building

Use `make`. The entire build from scratch takes about 40 minutes, and creates a ~1.5GB box file.
