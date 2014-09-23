require 'spec_helper'
require 'vSphere/util/vim_helpers'

describe VagrantPlugins::VSphere::Action::GetState do
  before :each do
    @env[:vSphere_connection] = @vim
  end

  it 'should set state id to not created if machine ID is not set' do
    call

    expect(@env[:machine_state_id]).to be :not_created
  end

  it 'should set state id to not created if VM is not found' do
    @env[:machine].stub(:id).and_return(MISSING_UUID)

    call

    expect(@env[:machine_state_id]).to be :not_created
  end

  it 'should set state id to running if machine is powered on' do
    @env[:machine].stub(:id).and_return(EXISTING_UUID)
    @vm.runtime.stub(:powerState).and_return(VagrantPlugins::VSphere::Util::VmState::POWERED_ON)

    call

    expect(@env[:machine_state_id]).to be :running
  end

  it 'should set state id to powered off if machine is powered off' do
    @env[:machine].stub(:id).and_return(EXISTING_UUID)
    @vm.runtime.stub(:powerState).and_return(VagrantPlugins::VSphere::Util::VmState::POWERED_OFF)

    call

    expect(@env[:machine_state_id]).to be :poweroff
  end

  it 'should set state id to powered off if machine is suspended' do
    @env[:machine].stub(:id).and_return(EXISTING_UUID)
    @vm.runtime.stub(:powerState).and_return(VagrantPlugins::VSphere::Util::VmState::SUSPENDED)

    call

    expect(@env[:machine_state_id]).to be :poweroff
  end

  it 'should call the next item in the middleware stack' do
    call

    expect(@app).to have_received :call
  end
end
