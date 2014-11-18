# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.require_version '>= 1.5.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'nginx-config-berkshelf'


  config.omnibus.chef_version = :latest
  config.vm.box = 'chef/centos-6.5'

  config.berkshelf.enabled = true
  config.berkshelf.berksfile_path = 'Berksfile'

  config.vm.provider 'virtualbox' do |vbox|
    vbox.customize ['modifyvm', :id, '--memory', 4096]
    vbox.customize ['modifyvm', :id, '--cpus', 2]
  end

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      nginx: {
        :servers => {
          :'sugar.pmsipilot.com' => {
            :port => 8888,
            :upstreams => {
              :sugar => {
                :ip => 'sugar',
                :port => 80
              }
            },
            :locations => [
              {
                :path => '/',
                :alias => '/sugar',
                :upstream => :sugar
              }
            ]
          }
        }
      }
    }

    chef.run_list = %w(
      recipe[nginx]
      recipe[nginx-config]
    )
  end
end
