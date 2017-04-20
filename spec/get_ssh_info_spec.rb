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

  context 'when acting on a VM with a single network adapter' do
    before do
      allow(@vm.guest).to receive(:ipAddress) { '127.0.0.2' }
      @env[:machine].stub(:id).and_return(EXISTING_UUID)
    end

    it 'should return the correct ip address' do
      call
      expect(@env[:machine_ssh_info][:host]).to eq '127.0.0.2'
    end
  end

  context 'when acting on a VM with multiple network adapters' do
    before do
      @env[:machine].stub(:id).and_return(EXISTING_UUID)
      allow(@vm.guest).to receive(:net) {
        [double('GuestNicInfo',
                ipAddress: ['bad address', '127.0.0.1'],
                deviceConfigId: 4000,
                ipConfig: double('NetIpConfigInfo',
                                 ipAddress: [double('NetIpConfigInfoIpAddress',
                                                    ipAddress: 'bad address', state: 'unknown'),
                                             double('NetIpConfigInfoIpAddress',
                                                    ipAddress: '127.0.0.1', state: 'preferred')]
                                )
               ),
         double('GuestNicInfo',
                ipAddress: ['bad address', '255.255.255.255'],
                deviceConfigId: -1,
                ipConfig: double('NetIpConfigInfo',
                                 ipAddress: [double('NetIpConfigInfoIpAddress',
                                                    ipAddress: 'bad address', state: 'unknown'),
                                             double('NetIpConfigInfoIpAddress',
                                                    ipAddress: '255.255.255.255', state: 'preferred')]
                                )
               )
        ]
      }
    end

    context 'when the real_nic_ip option is false' do
      it 'sets the ssh info the original adapter' do
        call
        expect(@env[:machine_ssh_info][:host]).to eq IP_ADDRESS
      end
    end

    context 'when the real_nic_ip option is true' do
      before do
        @env[:machine].provider_config.stub(:real_nic_ip).and_return(true)
      end
      context 'when there are mutiple valid adapters' do
        before do
          allow(@vm.guest).to receive(:net) {
            [double('GuestNicInfo',
                    ipAddress: ['bad address', '127.0.0.1'],
                    deviceConfigId: 4000,
                    ipConfig: double('NetIpConfigInfo',
                                     ipAddress: [double('NetIpConfigInfoIpAddress',
                                                        ipAddress: 'bad address', state: 'unknown'),
                                                 double('NetIpConfigInfoIpAddress',
                                                        ipAddress: '127.0.0.2', state: 'preferred')]
                                    )
                   ),
             double('GuestNicInfo',
                    ipAddress: ['bad address', '255.255.255.255'],
                    deviceConfigId: 2000,
                    ipConfig: double('NetIpConfigInfo',
                                     ipAddress: [double('NetIpConfigInfoIpAddress',
                                                        ipAddress: 'bad address', state: 'unknown'),
                                                 double('NetIpConfigInfoIpAddress',
                                                        ipAddress: '255.255.255.255', state: 'preferred')]
                                    )
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

      context 'when the VM networking is uninitialized' do
        before do
          allow(@vm.guest).to receive(:net) { [] }
          allow(@vm.guest).to receive(:ipAddress) { '123.234.156.78' }
        end
        it 'should set the ssh info to the guest ipAddress and port 22 if no valid adapters are present' do
          call
          expect(@env[:machine_ssh_info]).to eq(host: '123.234.156.78', port: 22)
        end
      end
    end
  end
end
