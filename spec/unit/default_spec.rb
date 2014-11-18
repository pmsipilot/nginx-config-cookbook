require 'spec_helper'

describe 'nginx-config::default' do
  describe 'Empty servers attribute' do
    let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }

    it 'Creates config file' do
      expect(chef_run).to render_file('/etc/nginx/sites-available/proxy.conf').with_content('')
    end

    it 'Enables nginx server' do
      template = chef_run.template('/etc/nginx/sites-available/proxy.conf')

      expect(template).to notify('link[enable_server]').to(:create).immediately
    end

    it 'Restarts nginx service' do
      template = chef_run.template('/etc/nginx/sites-available/proxy.conf')

      expect(template).to notify('service[nginx]').to(:restart).delayed
    end
  end
end
