require 'spec_helper'
require 'vSphere/action'
require 'vSphere/action/connect_vsphere'
require 'vagrant'

describe VagrantPlugins::VSphere::Action do
  describe 'up' do
    def run_up
      Vagrant::Action::Runner.new.run described_class.action_up, @env
    end

    it 'should connect to vSphere' do
      VagrantPlugins::VSphere::ConnectVSphere.any_instance.should_receive(:call)
      run_up
    end

    it 'should check if the VM exits' do

    end

    it 'should create the VM when the VM does already not exist' do

    end

    it 'should not create the VM when the VM already exists' do

    end
  end
end