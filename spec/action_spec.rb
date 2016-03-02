require 'spec_helper'
require 'vagrant'

describe VagrantPlugins::VSphere::Action do
  def run(action)
    Vagrant::Action::Runner.new.run described_class.send("action_#{action}"), @env
  end

  before :each do
    @machine.stub(:id).and_return(EXISTING_UUID)
    # Vagrant has some pretty buggy multi threading and their conditions
    # check can fail if the wait_for_ready method returns right away
    @machine.communicate.stub(:wait_for_ready) { sleep(1) }
  end

  describe 'up' do
    def run_up
      run :up
    end

    it 'should connect to vSphere' do
      VagrantPlugins::VSphere::Action::ConnectVSphere.any_instance.should_receive(:call)

      run_up
    end

    it 'should check if the VM exits' do
      VagrantPlugins::VSphere::Action::IsCreated.any_instance.should_receive(:call)

      run_up
    end

    it 'should create the VM when the VM does already not exist' do
      @machine.state.stub(:id).and_return(:not_created)

      VagrantPlugins::VSphere::Action::Clone.any_instance.should_receive(:call)

      run_up
    end

    it 'should not create the VM when the VM already exists' do
      @machine.state.stub(:id).and_return(:running)

      VagrantPlugins::VSphere::Action::Clone.any_instance.should_not_receive(:call)

      run_up
    end
  end

  describe 'destroy' do
    def run_destroy
      run :destroy
    end

    it 'should connect to vSphere' do
      VagrantPlugins::VSphere::Action::ConnectVSphere.any_instance.should_receive(:call)

      run_destroy
    end

    it 'should power off the VM' do
      @machine.state.stub(:id).and_return(:running)
      VagrantPlugins::VSphere::Action::PowerOff.any_instance.should_receive(:call)

      run_destroy
    end

    it 'should destroy the VM' do
      VagrantPlugins::VSphere::Action::Destroy.any_instance.should_receive(:call)

      run_destroy
    end
  end

  describe 'halt' do
    after :each do
      run :halt
    end

    it 'should connect to vSphere' do
      VagrantPlugins::VSphere::Action::ConnectVSphere.any_instance.should_receive(:call)
    end

    it 'should gracefully power off the VM' do
      @machine.state.stub(:id).and_return(:running)
      VagrantPlugins::VSphere::Action::GracefulHalt.any_instance.should_receive(:call)
    end
  end

  describe 'get state' do
    def run_get_state
      run :get_state
    end

    it 'should connect to vSphere' do
      VagrantPlugins::VSphere::Action::ConnectVSphere.any_instance.should_receive(:call)

      run_get_state
    end

    it 'should get the power state' do
      VagrantPlugins::VSphere::Action::GetState.any_instance.should_receive(:call)

      run_get_state
    end

    it 'should handle the values in a base vagrant box' do
      Vagrant::Action::Builtin::HandleBox.any_instance.should_receive(:call)

      run_get_state
    end
  end

  describe 'get ssh info' do
    def run_get_ssh_info
      run :get_ssh_info
    end

    it 'should connect to vSphere' do
      VagrantPlugins::VSphere::Action::ConnectVSphere.any_instance.should_receive(:call)

      run_get_ssh_info
    end

    it 'should get the power state' do
      VagrantPlugins::VSphere::Action::GetSshInfo.any_instance.should_receive(:call)

      run_get_ssh_info
    end
  end

  describe 'reload' do
    after :each do
      run :reload
    end

    it 'should gracefully power off the VM' do
      @machine.state.stub(:id).and_return(:running)

      VagrantPlugins::VSphere::Action::GracefulHalt.any_instance.should_receive(:call)
    end

    it 'should connect to vSphere' do
      VagrantPlugins::VSphere::Action::ConnectVSphere.any_instance.should_receive(:call)
    end

    it 'should check if the VM exits' do
      VagrantPlugins::VSphere::Action::IsCreated.any_instance.should_receive(:call)
    end

    it 'should not create the VM when the VM does already not exist' do
      @machine.state.stub(:id).and_return(:not_created)

      VagrantPlugins::VSphere::Action::Clone.any_instance.should_not_receive(:call)
      VagrantPlugins::VSphere::Action::MessageNotCreated.any_instance.should_receive(:call)
    end

    it 'should not create the VM when the VM already exists' do
      @machine.state.stub(:id).and_return(:running)

      VagrantPlugins::VSphere::Action::Clone.any_instance.should_not_receive(:call)
      VagrantPlugins::VSphere::Action::MessageAlreadyCreated.any_instance.should_receive(:call)
    end
  end
end
