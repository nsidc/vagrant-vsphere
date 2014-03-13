require 'rbvmomi'
require 'vSphere/errors'
require 'vSphere/action'
require 'vSphere/action/connect_vsphere'
require 'vSphere/action/close_vsphere'
require 'vSphere/action/is_created'
require 'vSphere/action/get_state'
require 'vSphere/action/get_ssh_info'
require 'vSphere/action/clone'
require 'vSphere/action/message_already_created'
require 'vSphere/action/message_not_created'
require 'vSphere/action/destroy'
require 'vSphere/action/power_off'

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

    provider_config = double(
        :host => 'testhost.com',
        :user => 'testuser',
        :password => 'testpassword',
        :data_center_name => nil,
        :compute_resource_name => 'testcomputeresource',
        :resource_pool_name => 'testresourcepool',
        :template_name => TEMPLATE,
        :name => NAME,
        :insecure => true,
        :validate => [],
        :customization_spec_name => nil,
        :data_store_name => nil,
        :clone_from_vm => nil,
        :linked_clone => nil)
    vm_config = double(
      :vm => double('config_vm', :synced_folders => [], :provisioners => [], :networks => [[:private_network, {:ip => '0.0.0.0'}]]),
      :validate => []
    )
    @app = double 'app', :call => true
    @machine = double 'machine',
                      :provider_config => provider_config,
                      :config => vm_config,
                      :state => double('state', :id => nil),
                      :communicate => double('communicator', :ready? => true),
                      :ssh_info => {},
                      :id => nil,
                      :id= => nil
    @env = {
        :machine => @machine,
        :ui => double('ui', :info => nil)
    }

    @vm = double('vm',
                 :runtime => double('runtime', :powerState => nil),
                 :guest => double('guest', :ipAddress => IP_ADDRESS),
                 :Destroy_Task => double('result', :wait_for_completion => nil),
                 :PowerOffVM_Task => double('result', :wait_for_completion => nil),
                 :PowerOnVM_Task => double('result', :wait_for_completion => nil))

    vm_folder = double('vm_folder')
    vm_folder.stub(:findByUuid).with(EXISTING_UUID).and_return(@vm)
    vm_folder.stub(:findByUuid).with(MISSING_UUID).and_return(nil)
    vm_folder.stub(:findByUuid).with(nil).and_return(nil)

    host_folder = double('host_folder')
    #We interrogate the type in vim_helpers.get_resource_pool, so make sure we act like a ResourcePool since that is easiest to mock
    host_folder.stub(:is_a?).with(RbVmomi::VIM::ResourcePool).and_return(true)
    host_folder.stub(:is_a?).with(RbVmomi::VIM::Folder).and_return(false)
    host_folder.stub(:is_a?).with(RbVmomi::VIM::ClusterComputeResource).and_return(false)
    host_folder.stub(:is_a?).with(RbVmomi::VIM::ComputeResource).and_return(false)
    host_folder.stub(:resourcePool).and_return(double('pools', :find => {}))

    @data_center = double('data_center',
                          :vmFolder => vm_folder,
                          :find_compute_resource => double('compute resource', :resourcePool => double('pools', :find => {})),
                          :hostFolder => host_folder)

    @template = double('template_vm',
                       :parent => @data_center,
                       :CloneVM_Task => double('result',
                                                :wait_for_completion => double('new_vm', :config => double('config', :uuid => NEW_UUID))))

    @data_center.stub(:find_vm).with(TEMPLATE).and_return(@template)

    service_instance = double 'service_instance', :find_datacenter => @data_center
    @ip = double 'ip', :ipAddress= => nil 
    customization_spec = double 'customization spec', :nicSettingMap => [double('nic setting', :adapter => double('adapter', :ip => @ip))]
    customization_spec.stub(:clone).and_return(customization_spec)
    customization_spec_manager = double 'customization spec manager', :GetCustomizationSpec => double('spec info', :spec => customization_spec)
    service_content = double 'service content', :customizationSpecManager => customization_spec_manager
    @vim = double 'vim', :serviceInstance => service_instance, :close => true, :serviceContent => service_content

    VIM.stub(:connect).and_return(@vim)
    VIM.stub(:VirtualMachineRelocateSpec).and_return({})
    VIM.stub(:VirtualMachineCloneSpec).and_return({})
  end
end
