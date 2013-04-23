require 'spec_helper'
require 'vSphere/action/is_created'

describe VagrantPlugins::VSphere::Action::IsCreated do
  before :each do
    @env[:vSphere_connection] = @vim
  end

  it 'should set result to false if the VM does not exist' do
    @env[:machine].state.stub(:id).and_return(:running)

    call

    @env[:result].should be true
  end

  it 'should set result to false if the VM does not exist' do
    @env[:machine].state.stub(:id).and_return(:not_created)

    call

    @env[:result].should be false
  end

  it 'should call the next item in the middleware stack' do
    call
    @app.should have_received :call
  end
end