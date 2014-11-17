require 'spec_helper'

describe 'nginx-config::default' do
  describe 'Server with upstream(s)' do
    describe 'Single upstream' do
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
        end.converge(described_recipe)
      end

      it 'Creates config file' do
        expected = <<CONF
upstream bar {
    server 10.0.0.1:9999;
}

server {
    listen *:8888;
    server_name foo;
    server_tokens off;

}
CONF

        expect(chef_run).to render_file('/etc/nginx/sites-available/proxy.conf').with_content(expected)
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

    describe 'Multiple upstreams' do
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
                          },
                          :baz => {
                              :ip => '10.0.0.2',
                              :port => 7777
                          }
                      }
                  }
              }
          }
        end.converge(described_recipe)
      end

      it 'Creates config file' do
        expected = <<CONF
upstream bar {
    server 10.0.0.1:9999;
}

upstream baz {
    server 10.0.0.2:7777;
}

server {
    listen *:8888;
    server_name foo;
    server_tokens off;

}
CONF

        expect(chef_run).to render_file('/etc/nginx/sites-available/proxy.conf').with_content(expected)
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
end
