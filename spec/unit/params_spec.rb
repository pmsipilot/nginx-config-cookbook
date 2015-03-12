require 'spec_helper'

describe 'nginx-config::default' do
  describe 'Params' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.set['nginx'] = {
          :sites_available => '/etc/nginx/sites-available',
          :sites_enabled => '/etc/nginx/sites-enabled',
          :servers => {}
        }
      end
    end

    describe 'Server context' do
      before do
        chef_run.node.set['nginx']['servers']['foo'] = {
          :root => '/var/www',
          :params => {
            :auth_basic => '"param"'
          }
        }
      end

      it 'Create a config file with an extra parameter' do
        expected = <<EOF
server {
    listen *:80;
    server_name foo;
    server_tokens off;
    root /var/www;
    auth_basic "param";

}
EOF

        expect(chef_run.converge(described_recipe)).to render_file('/etc/nginx/sites-available/foo.conf').with_content(expected)
      end
    end
    describe 'Location context' do
      before do
        chef_run.node.set['nginx']['servers']['foo'] = {
          :locations => [
                         {
                           :path => '/',
                           :upstream => 'bar',
                           :params => {
                             :auth_basic => '"param"'
                           }
                         }
                        ] 
        }
      end
      it 'Writes an extra parameter in the location section' do
        expected = <<EOF
server {
    listen *:80;
    server_name foo;
    server_tokens off;


    location / {
        proxy_pass http://bar/;
        proxy_redirect http://bar/ /;
        proxy_set_header Host $proxy_host;
        proxy_set_header X-Real-IP $remote_addr;
        auth_basic "param";
    }

}
EOF

        expect(chef_run.converge(described_recipe)).to render_file('/etc/nginx/sites-available/foo.conf').with_content(expected)
      end
    end
  end
end
