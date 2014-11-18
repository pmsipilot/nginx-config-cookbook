require 'spec_helper'

describe 'nginx-config::default' do
  describe 'Upstreams' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['nginx'] = {
            :sites_available => '/etc/nginx/sites-available',
            :sites_enabled => '/etc/nginx/sites-enabled',
            :servers => {
                :foo => {
                    :port => 8888,
                    :upstreams => {}
                }
            }
        }
      end
    end

    describe 'Single upstream' do
      before do
        chef_run.node.set['nginx']['servers']['foo']['upstreams']['bar'] = {
            :ip => '10.0.0.1',
            :port => 9999
        }
      end

      it 'Writes upstream in the server config file' do
        expected = <<CONF
upstream bar {
    server 10.0.0.1:9999;
}

CONF

        expect(chef_run.converge(described_recipe)).to render_file('/etc/nginx/sites-available/foo.conf').with_content(expected)
      end
    end

    describe 'Multiple upstreams' do
      before do
        chef_run.node.set['nginx']['servers']['foo']['upstreams']['bar'] = {
            :ip => '10.0.0.1',
            :port => 9999
        }

        chef_run.node.set['nginx']['servers']['foo']['upstreams']['baz'] = {
            :ip => '10.0.0.2',
            :port => 7777
        }
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

        expect(chef_run.converge(described_recipe)).to render_file('/etc/nginx/sites-available/foo.conf').with_content(expected)
      end
    end
  end
end
