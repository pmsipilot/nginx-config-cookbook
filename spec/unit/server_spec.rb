require 'spec_helper'

describe 'nginx-config::default' do
  describe 'Servers' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['nginx'] = {
            :sites_available => '/etc/nginx/sites-available',
            :sites_enabled => '/etc/nginx/sites-enabled',
            :servers => {}
        }
      end
    end

    describe 'Single server' do
      before do
        chef_run.node.set['nginx']['servers']['foo'] = {
            :root => '/var/www'
        }
      end

      it 'Creates a config file with the server name as filename' do
        expected = <<CONF
server {
    listen *:80;
    server_name foo;
    server_tokens off;
    root /var/www;

}
CONF

        expect(chef_run.converge(described_recipe)).to render_file('/etc/nginx/sites-available/foo.conf').with_content(expected)
      end

      it 'Enables nginx server' do
        chef_run.converge(described_recipe)

        template = chef_run.template('/etc/nginx/sites-available/foo.conf')
        link = chef_run.link('/etc/nginx/sites-enabled/foo.conf')

        expect(template).to notify('link[link_server_foo]').to(:create).immediately
        expect(link.to).to eq('/etc/nginx/sites-available/foo.conf')
        ChefSpec::Coverage.cover!(link)
      end

      it 'Restarts nginx service' do
        template = chef_run.converge(described_recipe).link('/etc/nginx/sites-enabled/foo.conf')

        expect(template).to notify('service[nginx]').to(:restart).delayed
      end
    end

    describe 'Multiple servers' do
      before do
        chef_run.node.set['nginx']['servers']['foo'] = {
            :root => '/var/www/foo'
        }

        chef_run.node.set['nginx']['servers']['bar'] = {
            :port => 9999,
            :root => '/var/www/bar'
        }
      end

      it 'Creates a config file for each server' do
        chef_run.node.set['nginx']['servers']['foo']['root'] = '/var/www/foo'
        chef_run.converge(described_recipe)

        expected_foo = <<CONF
server {
    listen *:80;
    server_name foo;
    server_tokens off;
    root /var/www/foo;

}
CONF

        expected_bar = <<CONF
server {
    listen *:9999;
    server_name bar;
    server_tokens off;
    root /var/www/bar;

}
CONF

        expect(chef_run).to render_file('/etc/nginx/sites-available/foo.conf').with_content(expected_foo)
        expect(chef_run).to render_file('/etc/nginx/sites-available/bar.conf').with_content(expected_bar)
      end

      it 'Enables nginx servers' do
        chef_run.converge(described_recipe)

        template_foo = chef_run.template('/etc/nginx/sites-available/foo.conf')
        link_foo = chef_run.link('/etc/nginx/sites-enabled/foo.conf')

        template_bar = chef_run.template('/etc/nginx/sites-available/bar.conf')
        link_bar = chef_run.link('/etc/nginx/sites-enabled/bar.conf')

        expect(template_foo).to notify('link[link_server_foo]').to(:create).immediately
        expect(link_foo.to).to eq('/etc/nginx/sites-available/foo.conf')
        ChefSpec::Coverage.cover!(link_foo)

        expect(template_bar).to notify('link[link_server_bar]').to(:create).immediately
        expect(link_bar.to).to eq('/etc/nginx/sites-available/bar.conf')
        ChefSpec::Coverage.cover!(link_bar)
      end

      it 'Restarts nginx service' do
        chef_run.converge(described_recipe)

        template_foo = chef_run.template('/etc/nginx/sites-available/foo.conf')
        template_bar = chef_run.template('/etc/nginx/sites-available/bar.conf')

        expect(template_foo).to notify('service[nginx]').to(:restart).delayed
        expect(template_bar).to notify('service[nginx]').to(:restart).delayed
      end
    end
  end
end
