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

  context 'when acting on a VM with multiple network adapters' do
    before do
      allow(@vm.guest).to receive(:ipAddress) { '127.0.0.2' }
      allow(@vm.guest).to receive(:net) {
        [
          double('guest_nic_info',
                 ipAddress: ['127.0.0.2', 'mac address'],
                 deviceConfigId: -1
                ),
          double('guest_nic_info',
                 ipAddress: ['127.0.0.1', 'mac address'],
                 deviceConfigId: 4000
                )
        ]
      }
      @env[:machine].stub(:id).and_return(EXISTING_UUID)
    end
    context 'when the real_nic_ip option is false' do
      it 'sets the ssh info the original adapter' do
        call
        expect(@env[:machine_ssh_info][:host]).to eq '127.0.0.2'
      end
    end

    context 'when the real_nic_ip option is true' do
      before do
        @env[:machine].provider_config.stub(:real_nic_ip).and_return(true)
      end
      context 'when there are mutiple valid adapters' do
        before do
          allow(@vm.guest).to receive(:net) {
            [
              double('guest_nic_info',
                     ipAddress: ['127.0.0.2', 'mac address'],
                     deviceConfigId: 4001
                    ),
              double('guest_nic_info',
                     ipAddress: ['127.0.0.1', 'mac address'],
                     deviceConfigId: 4000
                    )
            ]
          }
        end
        it 'should raise an error' do
          expect { call }.to raise_error(VagrantPlugins::VSphere::Errors::VSphereError)
        end
      end

      it 'sets the ssh info host to the correct adapter' do
        call
        expect(@env[:machine_ssh_info][:host]).to eq IP_ADDRESS
      end

    end
  end
end
