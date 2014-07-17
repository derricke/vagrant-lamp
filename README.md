# Vagrant LAMP

Basic LAMP development stack for Vagrant. 

## Installation

1. Install vagrant from [vagrantup.com](http://vagrantup.com/)
2. Download and Install VirtualBox from [virtualbox.org](http://www.virtualbox.org/) or use [VMware Fusion](http://www.vagrantup.com/vmware)
3. Ubuntu developer tools (If you're running ubuntu, skip if using Windows)
    ```
    $ sudo apt-get install linux-headers-generic build-essential dkms
    ```

4. Clone this repository to a folder of your choice (I have it in my user folder)
5. Add this row to your local machine's "hosts" file (Linux/Mac: "/etc/hosts")

    ```
    192.168.30.10 local.dev
    ```

6. Install helper plugins
    * [Guest Additions](https://docs.vagrantup.com/v2/virtualbox/boxes.html) Assists with folder syncing and various OS improvements
    ```
    $ vagrant plugin install vagrant-vbguest
    ```

7. Install helper gems
    * [Librarian](https://github.com/applicationsonline/librarian-chef) to automatically handle Chef cookbooks.

    ```
    $ gem install librarian-chef
    ```

8. Open Vagrantfile and uncomment/comment changes specific to your environment, some things to look for:
    
    * Choose OS, the default is Ubuntu 14.04 (Trusty.) Comment trusty, uncomment the lines for precise32 if you want to use that instead.
    * Ram Adjustments
    * Port Mapping
    * Synced Folders

9. Open bootstrap.sh and comment/uncomment changes to your specific setup.

10. Go to the repository folder and run librarian-chef install to download all required cookbooks.

    ```
    $ cd [repo]
    $ librarian-chef install
    ```

11. Still inside the repository [repo] folder, start the provisioning process
     
    ```
    $ vagrant up
    ```

12. Wait for vagrant to download, start and provision your virtual machine (this can take a while)
13. When the setup is done you can visit your local development host at http://local.dev/
14. Any files you add to the folder ```sites/local.dev/``` will be visible at http://local.dev/
15. Now you can configure your own sites, see the configuration section below.

## What's inside

Installed software:

* Apache
* MySQL
* php
* [Composer](http://getcomposer.org/)
* Laravel
* git, subversion
* Ruby
    * RVM
    * Gems
        * Rails
        * Passenger
        * Bundler
* Redmine


## Notes

The vagrant machine is set to use IP 192.168.30.10 by default.

If your firewall blocks port 80 incoming, uncomment #config.vm.network :forwarded_port, guest: 80, host: 8080 in Vagrantfile before provisioning
    * Sites would then be accessable via http://local.dev:8080/ or 
    * You can use [Fiddler](http://www.telerik.com/download/fiddler) to setup an outgoing proxy that you can use to still access http://local.dev/
        * Download [Fiddler](http://www.telerik.com/download/fiddler)
        * Goto Tools > Hosts
        * Check the box that say: Override remapping...
        * Add these lines. Fiddler also allows wildcard usage if you want to get fancy. You'll have to read their documentation.
        ```
        $ 192.168.30.10:8080   local.dev
        ```
        * Save and it should work correctly.

Port 33066 is forwarded to MySql, with a default vagrant/vagrant user so you can use your favorite client to administer databases.

## Sites configuration

Site configurations are stored in the ```sites-conf folder```. These conf files get copied over to the apache sites-enabled folder.

Whenever you need to apply new configurations all you need to do is run the provisioning again.

    $ vagrant provision


## Laravel

```laravel new``` command will create a fresh Laravel installation in the directory you specify. For instance, ```laravel new blog``` would create a directory named blog containing a fresh Laravel installation with all dependencies installed. 




