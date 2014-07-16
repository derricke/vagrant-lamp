# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  #################################
  # OS Setup                      #
  #################################

  #config.vm.box = "precise32"
  #config.vm.box_url = "http://files.vagrantup.com/precise32.box"
  
  config.vm.box = "trusty"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"


  #################################
  # VM Config                     #
  #################################
  
  # How long vagrant will attempt to ssh before giving up. Default is 300.
  config.vm.boot_timeout = 1000

  # Port mapping
  
  # Forward MySql port on 33066, used for connecting admin-clients to localhost:33066
  config.vm.network :forwarded_port, guest: 3306, host: 33066
  
  # Forward http port on 8080, used for connecting web browsers to localhost:8080
  #config.vm.network :forwarded_port, guest: 80, host: 8080
  
  # Create a private network, which allows host-only access to the machine using a specific IP.
  config.vm.network :private_network, ip: "192.168.33.10"

  # Create a bridged network, which allows PUBLIC access to the machine.
  #config.vm.network :public_network


  # Synced folders

  # Set share folder permissions to 777 so that apache can write files
  config.vm.synced_folder ".", "/vagrant", mount_options: ['dmode=777','fmode=666']
  #config.vm.synced_folder "./sites-files/", "/var/www", mount_options: ['dmode=777','fmode=666']
  config.vm.synced_folder "C:/web/www", "/var/www", mount_options: ['dmode=777','fmode=666']

  # If you want to share using NFS uncomment this line and comment the ones above
  # (30x faster performance on mac/linux hosts when using VirtualBox)
  # http://docs.vagrantup.com/v2/synced-folders/nfs.html
  #config.vm.synced_folder ".", "/vagrant", :nfs => true
  

  #VirtualBox Configuration
  config.vm.provider :virtualbox do |vb|

    # Uncomment to load with GUI (troubleshooting, manual input, etc)
    #vb.gui = true

    # If boot time is extremely long and you can see in the GUI that it's hanging on networking, you can uncomment these lines for possible fix
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

    # VirtualBox performance improvements
    # Found here: https://github.com/xforty/vagrant-drupal/blob/master/Vagrantfile
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
    vb.customize ["storagectl", :id, "--name", "SATAController", "--hostiocache", "off"]
    vb.customize ["modifyvm", :id, "--cpus", 1]  # Never set more than 1 cpu, degrades performance
    # Ram adjustments - RVM Ruby build tends to fail to build if using less than this (2GB). Default is 1024 (1GB)
    vb.customize ["modifyvm", :id, "--memory", "2048"]

  end


  #################################
  # Provisioning                  #
  #################################

  # Shell script (some things are just easier when typed in a single line)
  config.vm.provision :shell, path: "bootstrap.sh"

  
  # Chef (More complicated setups) 
  # Todo list, move more shell scripting to recipies, for now, this is a place holder
  config.vm.provision :chef_solo do |chef|

    # The librarian gem controls the "cookbook" folder, do not touch it. If you
    # need to create site-specific cookbooks, place them in "site-cookbooks".
    #chef.cookbooks_path = ["cookbooks", "cookbooks-custom"]

    # Path to data bags (our sites config)
    #chef.data_bags_path = "databags"

    # Default top level chef recipe
    #chef.add_recipe "vagrant_main"

    # Uncomment this to have chef spew out debug messages
    #chef.log_level = "debug"

    # Custom chef json configuration
    #chef.json.merge!({
    #  :tz => 'Europe/Stockholm',
    #  :mysql => {
    #    "server_root_password" => "vagrant",
    #    "server_debian_password" => "vagrant",
    #    "server_repl_password" => "vagrant"
    #  }
    #})

  end

end
