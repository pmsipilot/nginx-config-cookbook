require 'spec_helper'

describe 'PMSIpilot::NginxConfig::Server' do
  it 'Validates upstream config' do
    expect(PMSIpilot::NginxConfig::Server.valid?({ root: '/var/www' })).to eq(true)
    expect(PMSIpilot::NginxConfig::Server.valid?({ 'root' => '/var/www' })).to eq(true)

    expect(PMSIpilot::NginxConfig::Server.valid?({ port: 8080 })).to eq(false)
  end

  it 'Raises on invalid server config' do
    expect {
      PMSIpilot::NginxConfig::Server.raise_if_invalid!({ port: 8080 })
    }.to raise_error(Chef::Exceptions::ConfigurationError)
  end
end
