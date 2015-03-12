require 'serverspec'
require 'net/http'
require 'spec_helper'

def get_request(url, host)
  req = Net::HTTP::Get.new(url)
  req['Host'] = host
  Net::HTTP.new("127.0.0.1", 80).start {|http| http.request(req) }
end

describe package('nginx') do
  it { should be_installed }
end

describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
    it { should be_listening }
end

describe "Test webserver" do
  it "Get / on files.test" do
    response = get_request("/", "files.test")
    expect(response.code).to eq("200")
  end
  it "Get /test on upstream.test" do
    response = get_request("/test", "upstream.test")
    expect(response.code).to eq("404")
  end

end
