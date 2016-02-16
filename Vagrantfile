# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

  # Forward the Rails server default port to the host
  config.vm.network :forwarded_port, guest: 4000, host: 4000

  # Use Chef Solo to provision our virtual machine
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["cookbooks"]

    chef.add_recipe "apt"
    chef.add_recipe "nodejs"
    chef.add_recipe "ruby_build"
    chef.add_recipe "rvm::user"
    chef.add_recipe "rvm::vagrant"
    chef.add_recipe "vim"
    chef.add_recipe "mysql::server"
    chef.add_recipe "mysql::client"
    chef.add_recipe "system::install_packages"

    chef.json = {
      system: {
        packages: {
          install: ["libgmp-dev"]
        }
      },
      rvm: {
        user_installs: [
          {
            user: 'vagrant',
            default_ruby: 'ruby-2.2.2',
            rubies: [
              'ruby-2.2.2'
            ]
          }
        ],
        user_global_gems: [
          {
            name: 'bundler',
            version: '1.11.2'
          }
        ]
      },
      mysql: {
        server_root_password: ''
      }
    }
  end
end
