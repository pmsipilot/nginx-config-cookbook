require 'spec_helper'

describe 'PMSIpilot::NginxConfig::Upstream' do
  it 'Validates upstream config' do
    expect(PMSIpilot::NginxConfig::Upstream.valid?({ ip: '10.0.0.1' })).to eq(true)
    expect(PMSIpilot::NginxConfig::Upstream.valid?({ 'ip' => '10.0.0.1' })).to eq(true)

    expect(PMSIpilot::NginxConfig::Upstream.valid?({ port: 8080 })).to eq(false)
  end

  it 'Raises on invalid upstream config' do
    expect {
      PMSIpilot::NginxConfig::Upstream.raise_if_invalid!({ port: 8080 })
    }.to raise_error(Chef::Exceptions::ConfigurationError)
  end
end
