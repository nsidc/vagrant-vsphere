require 'spec_helper'
require 'vSphere/action/is_created'

describe VagrantPlugins::VSphere::Action::IsCreated do
  before :each do
    @env[:vSphere_connection] = @vim
  end

  it 'should set result to false if the VM does not exist' do
    @env[:machine].state.stub(:id).and_return(:running)

    call

    expect(@env[:result]).to be true
  end

  it 'should set result to false if the VM does not exist' do
    @env[:machine].state.stub(:id).and_return(:not_created)

    call

    expect(@env[:result]).to be false
  end

  it 'should call the next item in the middleware stack' do
    call
    expect(@app).to have_received :call
  end
end
