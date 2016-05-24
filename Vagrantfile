VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.omnibus.chef_version = :latest

  # Forward the Rails server default port to the host
  config.vm.network :forwarded_port, guest: 4000, host: 4000

  config.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 2
    end

  # fix default: stdin: is not a tty error on Ubuntu
  config.vm.provision "fix-no-tty", type: "shell" do |s|
      s.privileged = false
      s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  # Use Chef Solo to provision our virtual machine
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["cookbooks"]

    chef.add_recipe "apt"
    chef.add_recipe "ruby_build"
    chef.add_recipe "rvm::user"
    chef.add_recipe "rvm::vagrant"
    chef.add_recipe "vim"
    chef.add_recipe "nodejs"
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
            name: 'bundler'
          }
        ]
      },
      mysql: {
        server_root_password: ''
      }
    }
  end

  config.vm.provision 'shell', path: 'scripts/post_provision.sh', privileged: false
end
