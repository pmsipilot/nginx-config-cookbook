require 'spec_helper'

describe 'PMSIpilot::NginxConfig::Location' do
  it 'Validates upstream config' do
    expect(PMSIpilot::NginxConfig::Location.valid?({ path: '/', upstream: 'foo' })).to eq(true)
    expect(PMSIpilot::NginxConfig::Location.valid?({ 'path' => '/', 'upstream' => 'foo' })).to eq(true)

    expect(PMSIpilot::NginxConfig::Location.valid?({ path: '/' })).to eq(false)
  end

  it 'Raises on invalid server config' do
    expect {
      PMSIpilot::NginxConfig::Location.raise_if_invalid!({ path: '/' })
    }.to raise_error(Chef::Exceptions::ConfigurationError)
  end
end
