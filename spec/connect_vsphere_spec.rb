require 'spec_helper'

describe VagrantPlugins::VSphere::Action::ConnectVSphere do
  before :each do
    described_class.new(@app, @env).call(@env)
  end

  it 'should connect to vSphere' do
    expect(VIM).to have_received(:connect).with(
      host: @env[:machine].provider_config.host,
      user: @env[:machine].provider_config.user,
      password: @env[:machine].provider_config.password,
      insecure: @env[:machine].provider_config.insecure,
      proxyHost: @env[:machine].provider_config.proxy_host,
      proxyPort: @env[:machine].provider_config.proxy_port
    )
  end

  it 'should add the vSphere connection to the environment' do
    expect(@env[:vSphere_connection]).to be @vim
  end

  it 'should call the next item in the middleware stack' do
    expect(@app).to have_received :call
  end
end
