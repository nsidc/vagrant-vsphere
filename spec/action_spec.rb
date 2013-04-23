require 'spec_helper'
require 'vagrant'

describe VagrantPlugins::VSphere::Action do
  describe 'up' do
    def run_up
      Vagrant::Action::Runner.new.run described_class.action_up, @env
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

  describe 'get state' do
    it 'should connect to vSphere' do

    end

    it 'should get the power state' do

    end
  end
end