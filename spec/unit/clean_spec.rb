require 'spec_helper'

describe 'nginx-config::clean' do
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

  describe 'When server is disabled' do
    it 'Should delete config file' do
      chef_run.node.set['nginx']['servers']['foo']['enable'] = false

      expect(chef_run.converge(described_recipe)).to delete_file('delete_server_foo')
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
