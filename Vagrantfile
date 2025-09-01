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

  # Porte
  config.vm.network "forwarded_port", guest: 22,   host: 2222, id: "ssh", auto_correct: true
  config.vm.network "forwarded_port", guest: 8081, host: 8081,              auto_correct: true
  config.vm.network "forwarded_port", guest: 8100, host: 8100,              auto_correct: true

  # Cache Rlibs condivisa (usa se presente, così non ricompila tutto ogni volta)
  config.vm.synced_folder "./.rlibs", "/opt/Rlibs",
    create: true, owner: "vagrant", group: "vagrant", mount_options: ["dmode=775,fmode=664"]

  config.vm.provider "virtualbox" do |vb|
    vb.gui    = true
    vb.memory = 8192   # 🔼 portata a 8 GB per evitare OOM con R
    vb.cpus   = 4      # 🔼 portato a 4 core per build più veloce

    # Opzioni di compatibilità / stabilità
    vb.customize ["modifyvm", :id, "--nictype1", "Am79C973"]
    vb.customize ["modifyvm", :id, "--paravirtprovider", "legacy"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--pae", "on"]
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--usbxhci", "off"]

    # Migliora stabilità I/O con cartelle condivise
    vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]
  end

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  # Fix per TTY
  config.vm.provision "fix-no-tty", type: "shell", privileged: true,
    inline: "sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"

  # Mirror più veloce
  config.vm.provision "local-mirror", type: "shell", privileged: true,
    inline: "sed -i 's|http://[a-z\\.]*\\.ubuntu\\.com/ubuntu|mirror://mirrors\\.ubuntu\\.com/mirrors\\.txt|' /etc/apt/sources.list"

  # Provision disabilitati: non parte più automaticamente
  config.vm.provision "build", type: "shell", privileged: false, inline: $build
  # config.vm.provision "test", type: "shell", privileged: false,
  #   inline: "cd /vagrant && bash integration-scripts/test_codeface.sh"
end
