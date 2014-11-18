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
end
