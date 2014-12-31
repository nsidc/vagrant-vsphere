require 'spec_helper'

describe VagrantPlugins::VSphere::Action::GetSshInfo do
  before :each do
    @env[:vSphere_connection] = @vim
  end

  it 'should set the ssh info to nil if machine ID is not set' do
    call

    expect(@env.key?(:machine_ssh_info)).to be true
    expect(@env[:machine_ssh_info]).to be nil
  end

  it 'should set the ssh info to nil for a VM that does not exist' do
    @env[:machine].stub(:id).and_return(MISSING_UUID)

    call

    expect(@env.key?(:machine_ssh_info)).to be true
    expect(@env[:machine_ssh_info]).to be nil
  end

  it 'should set the ssh info host to the IP an existing VM' do
    @env[:machine].stub(:id).and_return(EXISTING_UUID)

    call

    expect(@env[:machine_ssh_info][:host]).to be IP_ADDRESS
  end
end
