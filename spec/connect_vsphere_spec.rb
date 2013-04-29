require 'spec_helper'

describe VagrantPlugins::VSphere::Action::ConnectVSphere do
  before :each do
    described_class.new(@app, @env).call(@env)
  end

  it 'should connect to vSphere' do
    VIM.should have_received(:connect).with({
      :host => @env[:machine].provider_config.host,
      :user => @env[:machine].provider_config.user,
      :password => @env[:machine].provider_config.password,
      :insecure => @env[:machine].provider_config.insecure,
    })
  end

  it 'should add the vSphere connection to the environment' do
    @env[:vSphere_connection].should be @vim
  end

  it 'should call the next item in the middleware stack' do
    @app.should have_received :call
  end
end