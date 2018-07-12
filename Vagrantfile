# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box = "thezecke11/windows_7"
    config.vm.box_version = "1.0.0"
    config.vm.guest = :windows

    config.vm.define "workflow-dev"

    config.vm.hostname = "workflow"

    config.vm.provider :virtualbox do |vb|
        vb.name = "workflow-dev"
    end

    config.vm.communicator = "winrm"

    # Max time to wait for the guest to shutdown
    config.windows.halt_timeout = 25

    config.winrm.username = "vagrant"
    config.winrm.password = "vagrant"

    # Port forward WinRM and RDP, LDAP (non-SSL)
    config.vm.network :forwarded_port, guest: 3389, host: 3389
    config.vm.network :forwarded_port, guest: 5986, host: 5986
    config.vm.network :forwarded_port, guest: 5985, host: 5985
    config.vm.network :forwarded_port, guest: 389, host: 1389
    config.vm.network :forwarded_port, guest: 22, host: 2223

    config.vm.network :private_network, ip: "192.168.3.101"

    config.vm.provider :virtualbox do |v|
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["modifyvm", :id, "--memory", 2048]
        v.customize ["modifyvm", :id, "--cpus", 2]
        v.customize ["modifyvm", :id, "--name", "workflow-dev"]
        v.gui = false
    end

    if defined?(VagrantPlugins::HostsUpdater)
        # Pass the host names to the hostsupdater plugin
        config.hostsupdater.aliases = ["site.dev"]
        # Remove the hosts changes on suspend
        config.hostsupdater.remove_on_suspend = false
    end

    # config.ssh.private_key_path = "id_rsa"
    # config.ssh.port = 2223

    config.vm.synced_folder ".", "/Users/vagrant", type: "rsync", rsync__exclude: [
        ".vagrant"
    ]

    # Configure the window for gatling to coalesce writes.
    if Vagrant.has_plugin?("vagrant-gatling-rsync")
        config.gatling.latency = 1.5
        config.gatling.time_format = "%H:%M:%S"
    end

    # Trigger rsyncing of files after an up/resume/reload
    if Vagrant.has_plugin?("vagrant-triggers")
        config.trigger.after [:up, :resume, :reload] do
            run "vagrant gatling-rsync-auto"
        end
    end

    # config.berkshelf.berksfile_path = "Berksfile"
    # config.berkshelf.enabled = true

  # config.vm.provision "chef_solo" do |chef|

  #   chef.json = {
  #     <CHEF CONFIG>
  #   }

    # chef.run_list = [
    #     "recipe[initial-setup::iis]",
    #     "recipe[initial-setup::sqlsrv]"
    # ]
    # end

    # config.vm.provision "shell" do |s|
    #     s.path = "provision.bat"
    # end

    # config.vm.provision "shell", run: "always" do |s|
    #     s.path = "up.bat"
    # end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
