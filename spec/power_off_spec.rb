require 'spec_helper'

describe VagrantPlugins::VSphere::Action::PowerOff do
  before :each do
    @env[:vSphere_connection] = @vim
  end

  it 'should power off the VM if it is powered on' do
    @machine.provider.driver.stub(:powered_off?).and_return(false)

    call

    expect(@machine.provider.driver).to have_received :power_off_vm
  end

  it 'should not power off the VM if is powered off' do
    @machine.provider.driver.stub(:powered_off?).and_return(true)

    call

    expect(@machine.provider.driver).not_to have_received :power_off_vm
  end

  it 'should power on and off the VM if is suspended' do
    @machine.provider.driver.stub(:suspended?).and_return(true)
    @machine.provider.driver.stub(:powered_off?).and_return(false)

    call

    expect(@machine.provider.driver).to have_received :power_on_vm
    expect(@machine.provider.driver).to have_received :power_off_vm
  end
end
