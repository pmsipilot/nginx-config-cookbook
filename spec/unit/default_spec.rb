require 'spec_helper'

describe 'nginx-config::default' do
  describe 'With empty servers attribute' do
    it 'Throws a ConfigurationError with empty attributes' do
      expect { ChefSpec::SoloRunner.new.converge(described_recipe) }.to raise_error(Chef::Exceptions::ConfigurationError)
    end

    it 'Throws a ConfigurationError with empty servers' do
      chef_run = ChefSpec::SoloRunner.new do |node|
        node.set['nginx'] = {
            :servers => {}
        }
      end

      expect { chef_run.converge(described_recipe) }.to raise_error(Chef::Exceptions::ConfigurationError)
    end

    it 'Throws a ConfigurationError with invalid server definition' do
      chef_run = ChefSpec::SoloRunner.new do |node|
        node.set['nginx'] = {
          :servers => {
              :foo => {}
          }
        }
      end

      expect { chef_run.converge(described_recipe) }.to raise_error(Chef::Exceptions::ConfigurationError)
    end
  end

  describe 'With servers attribute' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['nginx'] = {
            :servers => {
                :foo => {
                    :port => 8888,
                    :root => '/'
                }
            }
        }
      end
    end

    it 'Set default attributes values' do
      node = chef_run.converge(described_recipe).node

      expect(node['nginx']['dir']).to eq('/etc/nginx')
      expect(node['nginx']['sites_available']).to eq('/etc/nginx/conf.d')
      expect(node['nginx']['sites_enabled']).to eq('/etc/nginx/conf.d')
    end

    it 'Declares nginx service and does nothing' do
      service = chef_run.converge(described_recipe).service('nginx')

      expect(service).to do_nothing
    end

    it 'Declares server link resource and does nothing' do
      link = chef_run.converge(described_recipe).link('link_server_foo')

      expect(link).to do_nothing
    end

    it 'Should not create symlink if enabled/available directories are the same' do
      expect(chef_run.converge(described_recipe)).to_not create_link('/etc/nginx/conf.d/foo.conf')
    end

    describe 'When server is disabled' do
      it 'Should delete config file' do
        chef_run.node.set['nginx']['servers']['foo']['enable'] = false

        expect(chef_run.converge(described_recipe)).to delete_template('delete_server_foo')
      end

      it 'Should delete symlink' do
        chef_run.node.set['nginx']['sites_available'] = '/etc/nginx/sites-available'
        chef_run.node.set['nginx']['sites_enabled'] = '/etc/nginx/sites-enabled'
        chef_run.node.set['nginx']['servers']['foo']['enable'] = false

        expect(chef_run.converge(described_recipe)).to_not delete_template('delete_server_foo')
        expect(chef_run.converge(described_recipe)).to delete_link('unlink_server_foo')
      end
    end
  end
end
