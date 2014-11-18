require 'spec_helper'

describe 'nginx-config::default' do
  describe 'Upstreams' do
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

      it 'Writes upstream in the server config file' do
        expected = <<CONF
upstream bar {
    server 10.0.0.1:9999;
}

CONF

        expect(chef_run).to render_file('/etc/nginx/sites-available/foo.conf').with_content(expected)
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

      it 'Writes upstreams in the server config file' do
        expected = <<CONF
upstream bar {
    server 10.0.0.1:9999;
}

upstream baz {
    server 10.0.0.2:7777;
}

CONF

        expect(chef_run).to render_file('/etc/nginx/sites-available/foo.conf').with_content(expected)
      end
    end
  end
end
