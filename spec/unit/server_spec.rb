require 'spec_helper'

describe 'nginx-config::default' do
  describe 'Simple server' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['nginx'] = {
            :servers => {
                :foo => {
                    :port => 8888,
                    :upstreams => {
                        :bar => {
                            :ip => '10.0.0.1',
                            :port => 9999
                        }
                    }
                }
            }
        }
      end
    end

    it 'Creates a config file with the server name as filename' do
      expected = <<CONF
server {
    listen *:8888;
    server_name foo;
    server_tokens off;


}
CONF

      expect(chef_run.converge(described_recipe)).to render_file('/etc/nginx/sites-available/foo.conf').with_content(expected)
    end

    it 'Writes the document root directive in the server section' do
      chef_run.node.set['nginx']['servers']['foo']['root'] = '/var/www/foo'

      expected = <<CONF
server {
    listen *:8888;
    server_name foo;
    server_tokens off;
    root /var/www/foo;

}
CONF

      expect(chef_run.converge(described_recipe)).to render_file('/etc/nginx/sites-available/foo.conf').with_content(expected)
    end

    it 'Enables nginx server' do
      template = chef_run.converge(described_recipe).template('/etc/nginx/sites-available/foo.conf')

      expect(template).to notify('link[enable_server]').to(:create).immediately
    end

    it 'Restarts nginx service' do
      template = chef_run.converge(described_recipe).template('/etc/nginx/sites-available/foo.conf')

      expect(template).to notify('service[nginx]').to(:restart).delayed
    end
  end
end
