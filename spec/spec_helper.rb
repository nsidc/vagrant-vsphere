require 'rbvmomi'
require 'pathname'
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
  # removes deprecation warnings.
  # http://stackoverflow.com/questions/20275510/how-to-avoid-deprecation-warning-for-stub-chain-in-rspec-3-0/20296359#20296359
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.before(:each) do
    def call
      described_class.new(@app, @env).call(@env)
    end

    provider_config = double(
        host: 'testhost.com',
        user: 'testuser',
        password: 'testpassword',
        data_center_name: nil,
        compute_resource_name: 'testcomputeresource',
        resource_pool_name: 'testresourcepool',
        vm_base_path: nil,
        template_name: TEMPLATE,
        name: NAME,
        insecure: true,
        validate: [],
        customization_spec_name: nil,
        data_store_name: nil,
        clone_from_vm: nil,
        linked_clone: nil,
        proxy_host: nil,
        proxy_port: nil,
        vlan: nil,
        memory_mb: nil,
        cpu_count: nil,
        mac: nil,
        addressType: nil,
        cpu_reservation: nil,
        mem_reservation: nil,
        custom_attributes: {})
    vm_config = double(
      vm: double('config_vm',
                 box: nil,
                 synced_folders: [],
                 provisioners: [],
                 hostname: nil,
                 communicator: nil,
                 networks: [[:private_network, { ip: '0.0.0.0' }]],
                 graceful_halt_timeout: 0.1),
      validate: []
    )
    @app = double 'app', call: true
    @machine = double 'machine',
                      :provider_config => provider_config,
                      :config => vm_config,
                      :state => double('state', id: nil),
                      :communicate => double('communicator', :ready? => true),
                      :ssh_info => {},
                      :data_dir => Pathname.new(''),
                      :id => nil,
                      :id= => nil,
                      :guest => double('guest', capability: nil)

    @env = {
      machine: @machine,
      ui: double('ui', info: nil, output: nil)
    }

    @vm = double('vm',
                 runtime: double('runtime', powerState: nil),
                 guest: double('guest', ipAddress: IP_ADDRESS),
                 Destroy_Task: double('result', wait_for_completion: nil),
                 PowerOffVM_Task: double('result', wait_for_completion: nil),
                 PowerOnVM_Task: double('result', wait_for_completion: nil))

    vm_folder = double('vm_folder')
    vm_folder.stub(:findByUuid).with(EXISTING_UUID).and_return(@vm)
    vm_folder.stub(:findByUuid).with(MISSING_UUID).and_return(nil)
    vm_folder.stub(:findByUuid).with(nil).and_return(nil)

    @child_resource_pool = double('testresourcepool')
    @root_resource_pool = double('pools', find: @child_resource_pool)

    @compute_resource = RbVmomi::VIM::ComputeResource.new(nil, nil)
    @compute_resource.stub(:resourcePool).and_return(@root_resource_pool)

    @host_folder = double('hostFolder', childEntity: double('childEntity', find: @compute_resource))

    @data_center = double('data_center',
                          vmFolder: vm_folder,
                          pretty_path: "data_center/#{vm_folder}",
                          find_compute_resource: @compute_resource,
                          hostFolder: @host_folder)

    @device = RbVmomi::VIM::VirtualEthernetCard.new
    @device.stub(:backing).and_return(RbVmomi::VIM::VirtualEthernetCardNetworkBackingInfo.new)

    @virtual_hardware = double('virtual_hardware',
                               device: [@device])
    @template_config = double('template_config',
                              hardware: @virtual_hardware)

    @template = double('template_vm',
                       parent: @data_center,
                       pretty_path: "#{@data_center.pretty_path}/template_vm",
                       CloneVM_Task: double('result',
                                            wait_for_completion: double('new_vm', config: double('config', uuid: NEW_UUID))),
                       config: @template_config)

    @data_center.stub(:find_vm).with(TEMPLATE).and_return(@template)

    service_instance = double 'service_instance', find_datacenter: @data_center
    @ip = double 'ip', :ipAddress= => nil
    @customization_spec = double 'customization spec', nicSettingMap: [double('nic setting', adapter: double('adapter', ip: @ip))]
    @customization_spec.stub(:clone).and_return(@customization_spec)
    customization_spec_manager = double 'customization spec manager', GetCustomizationSpec: double('spec info', spec: @customization_spec)
    service_content = double 'service content', customizationSpecManager: customization_spec_manager
    @vim = double 'vim', serviceInstance: service_instance, close: true, serviceContent: service_content

    VIM.stub(:connect).and_return(@vim)
    VIM.stub(:VirtualMachineRelocateSpec).and_return({})
    VIM.stub(:VirtualMachineCloneSpec) { |location, _powerOn, _template| { location: location[:location] } }
  end
end
