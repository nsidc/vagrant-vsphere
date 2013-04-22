require 'spec_helper'
require 'vSphere/action/is_created'

describe VagrantPlugins::VSphere::IsCreated do
  before :each do
    @env[:vSphere_connection] = @vim
    described_class.new(@app, @env).call(@env)
  end

  it 'should set result to false if the VM does not exist' do

  end

  it 'should call the next item in the middleware stack' do
    @app.should have_received :call
  end
end