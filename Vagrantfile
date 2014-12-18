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

  config.vm.network "private_network", ip: "192.168.50.4"
  config.vm.provider 'virtualbox' do |vbox|
    vbox.customize ['modifyvm', :id, '--memory', 1024]
    vbox.customize ['modifyvm', :id, '--cpus', 2]
  end

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      nginx: {
        :servers => {
          :'sugar.pmsipilot.com' => {
            :port => 80,
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
                :protocol => 'http',
                :upstream => :sugar

              }
            ]
          },
          :'demobi.pmsipilot.com' => {
            :port => 80,
            :upstreams => {
              :demobi => {
                :ip => 'srv-demo-pbi1',
                :port => 443

              }
            },
            :locations => [
              {

                :path => '/',
                :alias => '/',
                :protocol => 'https',
                :upstream => 'srv-demo-pbi1'


              }

            ]



          },
          :'demo.pmsipilot.com' => {

            :port => 80,
            :upstreams => {
              :demo => {
              :ip => 'srv-demo',
              :port => 80


           }

         },


        :locations => [

          {
          :path => '/',
          :protocol => 'http',
          :upstream => 'srv-demo'
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
