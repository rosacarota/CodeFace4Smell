# -*- mode: ruby -*-
# vi: set ft=ruby :

$build = <<SCRIPT
cd /vagrant

bash integration-scripts/install_repositories.sh
bash integration-scripts/install_common.sh
bash integration-scripts/install_codeface_R.sh
bash integration-scripts/install_codeface_node.sh
bash integration-scripts/install_codeface_python.sh

bash integration-scripts/install_cppstats.sh
bash integration-scripts/setup_database.sh
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.boot_timeout = 1800
  config.ssh.insert_key = true

  config.vm.network "forwarded_port", guest: 22,   host: 2222, id: "ssh", auto_correct: true
  config.vm.network "forwarded_port", guest: 8081, host: 8081,              auto_correct: true
  config.vm.network "forwarded_port", guest: 8100, host: 8100,              auto_correct: true

  # NIENTE mount .rlibs per ora
  config.vm.synced_folder "./.rlibs", "/opt/Rlibs", 
    create: true, owner: "vagrant", group: "vagrant"


  config.vm.provider "virtualbox" do |vb|
    vb.gui    = true
    vb.memory = 4096
    vb.cpus   = 2
    vb.customize ["modifyvm", :id, "--nictype1", "Am79C973"]     # NIC super compatibile
    vb.customize ["modifyvm", :id, "--paravirtprovider", "legacy"]# evita freeze su xor
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--pae", "on"]
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
    vb.customize ["modifyvm", :id, "--audio", "none"]             # riduce interferenze
    vb.customize ["modifyvm", :id, "--usbxhci", "off"]            # idem
  end

  # ❌ rimuoviamo completamente il provider LXC
  # config.vm.provider :lxc do |lxc, override| ... end

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  config.vm.provision "fix-no-tty", type: "shell", privileged: true,
    inline: "sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"

  config.vm.provision "local-mirror", type: "shell", privileged: true,
    inline: "sed -i 's|http://[a-z\\.]*\\.ubuntu\\.com/ubuntu|mirror://mirrors\\.ubuntu\\.com/mirrors\\.txt|' /etc/apt/sources.list"

  config.vm.provision "build", type: "shell", privileged: false, inline: $build
  config.vm.provision "test",  type: "shell", privileged: false,
    inline: "cd /vagrant && bash integration-scripts/test_codeface.sh"
end

