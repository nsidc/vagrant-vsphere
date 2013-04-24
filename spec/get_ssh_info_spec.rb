require 'spec_helper'

describe VagrantPlugins::VSphere::Action::GetSshInfo do
  before :each do
    @env[:vSphere_connection] = @vim
  end

  it 'should set the ssh info to nil if machine ID is not set' do
    call

    @env.has_key?(:machine_ssh_info).should be true
    @env[:machine_ssh_info].should be nil
  end

  it 'should set the ssh info to nil for a VM that does not exist' do
    @env[:machine].stub(:id).and_return(MISSING_UUID)

    call

    @env.has_key?(:machine_ssh_info).should be true
    @env[:machine_ssh_info].should be nil
  end

  it 'should set the ssh info host to the IP an existing VM' do
    @env[:machine].stub(:id).and_return(EXISTING_UUID)

    call

    @env[:machine_ssh_info][:host].should be IP_ADDRESS
  end
end