require 'spec_helper'
require 'vagrant'

describe VagrantPlugins::VSphere::Action do
  def run(action)
    Vagrant::Action::Runner.new.run described_class.send("action_#{action}"), @env
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
      @env[:machine].state.stub(:id).and_return(:not_created)

      VagrantPlugins::VSphere::Action::Clone.any_instance.should_receive(:call)

      run_up
    end

    it 'should not create the VM when the VM already exists' do
      @env[:machine].state.stub(:id).and_return(:running)

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
end