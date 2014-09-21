require 'spec_helper'

describe VagrantPlugins::VSphere::Action::PowerOff do
  before :each do
    @env[:vSphere_connection] = @vim
  end

  it 'should power off the VM if it is powered on' do
    @machine.stub(:id).and_return(EXISTING_UUID)
    @machine.state.stub(:id).and_return(VagrantPlugins::VSphere::Util::VmState::POWERED_ON)

    call

    expect(@vm).to have_received :PowerOffVM_Task
  end

  it 'should not power off the VM if is powered off' do
    @machine.stub(:id).and_return(EXISTING_UUID)
    @vm.runtime.stub(:powerState).and_return(VagrantPlugins::VSphere::Util::VmState::POWERED_OFF)

    call

    expect(@vm).not_to have_received :PowerOffVM_Task
  end

  it 'should power on and off the VM if is suspended' do
    @machine.stub(:id).and_return(EXISTING_UUID)
    @vm.runtime.stub(:powerState).and_return(VagrantPlugins::VSphere::Util::VmState::SUSPENDED)

    call

    expect(@vm).to have_received :PowerOnVM_Task
    expect(@vm).to have_received :PowerOffVM_Task
  end
end
