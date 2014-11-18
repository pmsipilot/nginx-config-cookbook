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

    it 'Declares nginx service and does nothing' do
      service = chef_run.converge(described_recipe).service('nginx')

      expect(service).to do_nothing
    end

    it 'Declares server link resource and does nothing' do
      link = chef_run.converge(described_recipe).link('enable_server_foo')

      expect(link).to do_nothing
    end
  end
end
