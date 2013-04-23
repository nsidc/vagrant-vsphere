require 'spec_helper'

describe VagrantPlugins::VSphere::Action::GetState do
  before :each do
    @env[:vSphere_connection] = @vim
  end

  it 'should set state id to not created if machine ID is not set' do
    call

    @env[:machine_state_id].should be :not_created
  end

  it 'should set state id to not created if VM is not found' do
    @env[:machine].stub(:id).and_return(MISSING_UUID)

    call

    @env[:machine_state_id].should be :not_created
  end

  it 'should set state id to running if machine is powered on' do
    @env[:machine].stub(:id).and_return(EXISTING_UUID)
    @vm.runtime.stub(:powerState).and_return(described_class::POWERED_ON)

    call

    @env[:machine_state_id].should be :running
  end

  it 'should set state id to powered off if machine is powered off' do
    @env[:machine].stub(:id).and_return(EXISTING_UUID)
    @vm.runtime.stub(:powerState).and_return(described_class::POWERED_OFF)

    call

    @env[:machine_state_id].should be :poweroff
  end

  it 'should set state id to powered off if machine is suspended' do
    @env[:machine].stub(:id).and_return(EXISTING_UUID)
    @vm.runtime.stub(:powerState).and_return(described_class::SUSPENDED)

    call

    @env[:machine_state_id].should be :poweroff
  end

  it 'should call the next item in the middleware stack' do
    call

    @app.should have_received :call
  end
end
