require 'spec_helper'

describe 'nginx-config::default' do
  describe 'Locations' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['nginx'] = {
            :servers => {
                :foo => {
                    :port => 8888,
                    :locations => []
                }
            }
        }
      end
    end

    describe 'With invalid location attribute' do
        it 'Throws a ConfigurationError with empty attributes' do
            chef_run.node.set['nginx']['servers']['foo']['locations'] << {}

            expect { chef_run.converge(described_recipe) }.to raise_error(Chef::Exceptions::ConfigurationError)
        end

        it 'Throws a ConfigurationError with empty upstream' do
          chef_run.node.set['nginx']['servers']['foo']['locations'] << {
              :path => '/'
          }

          expect { chef_run.converge(described_recipe) }.to raise_error(Chef::Exceptions::ConfigurationError)
        end
    end

    describe 'Single location' do
      before do
        chef_run.node.set['nginx']['servers']['foo']['locations'] << {
            :path => '/',
            :upstream => 'bar'
        }
      end

      it 'Writes location in the server section' do
        expected = <<CONF
server {
    listen *:8888;
    server_name foo;
    server_tokens off;


    location / {
        proxy_pass http://bar/;
        proxy_redirect http://bar/ /;
        proxy_set_header Host $proxy_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }

}
CONF

        expect(chef_run.converge(described_recipe)).to render_file('/etc/nginx/conf.d/foo.conf').with_content(expected)
      end
    end

    describe 'Multiple locations' do
      before do
        chef_run.node.set['nginx']['servers']['foo']['locations'] << {
            :path => '/',
            :upstream => 'bar'
        }

        chef_run.node.set['nginx']['servers']['foo']['locations'] << {
            :path => '/baz',
            :upstream => 'baz'
        }
      end

      it 'Writes locations in the server section' do
        expected = <<CONF
server {
    listen *:8888;
    server_name foo;
    server_tokens off;


    location / {
        proxy_pass http://bar/;
        proxy_redirect http://bar/ /;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }

    location /baz {
        proxy_pass http://baz/;
        proxy_redirect http://baz/ /;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
    }

}
CONF

        expect(chef_run.converge(described_recipe)).to render_file('/etc/nginx/conf.d/foo.conf').with_content(expected)
      end
    end
  end
end
