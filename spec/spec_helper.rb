require 'rspec-spies'
require 'rbvmomi'
require 'vSphere/errors'
require 'vSphere/action'
require 'vSphere/action/connect_vsphere'
require 'vSphere/action/close_vsphere'
require 'vSphere/action/is_created'
require 'vSphere/action/get_state'
require 'vSphere/action/get_ssh_info'
require 'vSphere/action/clone'

VIM = RbVmomi::VIM

EXISTING_UUID = 'existing_uuid'
MISSING_UUID = 'missing_uuid'
NEW_UUID = 'new_uuid'
TEMPLATE = 'template'
NAME = 'vm'
IP_ADDRESS = '127.0.0.1'

RSpec.configure do |config|
  config.before(:each) do
    def call
      described_class.new(@app, @env).call(@env)
    end

    config = double(
        :host => 'testhost.com',
        :user => 'testuser',
        :password => 'testpassword',
        :data_center_name => nil,
        :template_name => TEMPLATE,
        :name => NAME,
        :validate => [])
    @app = double 'app', :call => true
    @env = {
        :machine => double('machine',
                           :provider_config => config,
                           :config => config,
                           :state => double('state', :id => nil),
                           :id => nil,
                           :id= => nil)
    }

    @vm = double('vm',
                 :runtime => double('runtime', :powerState => nil),
                 :guest => double('guest', :ipAddress => IP_ADDRESS))

    vm_folder = double('vm_folder')
    vm_folder.stub(:findByUuid).with(EXISTING_UUID).and_return(@vm)
    vm_folder.stub(:findByUuid).with(MISSING_UUID).and_return(nil)

    @data_center = double('data_center', :vmFolder => vm_folder)

    @template = double('template_vm',
                       :parent => @data_center,
                       :CloneVM_Task => double('result',
                                                :wait_for_completion => double('new_vm', :config => double('config', :uuid => NEW_UUID))))

    @data_center.stub(:find_vm).with(TEMPLATE).and_return(@template)

    service_instance = double 'service_instance', :find_datacenter => @data_center

    @vim = double 'vim', :serviceInstance => service_instance, :close => true

    VIM.stub(:connect).and_return(@vim)
    VIM.stub(:VirtualMachineRelocateSpec).and_return({})
    VIM.stub(:VirtualMachineCloneSpec).and_return({})
  end
end
