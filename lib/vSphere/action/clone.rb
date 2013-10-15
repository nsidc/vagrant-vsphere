require 'rbvmomi'
require 'i18n'
require 'vSphere/util/vim_helpers'
require 'vSphere/util/machine_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class Clone
        include Util::VimHelpers
        include Util::MachineHelpers

        def initialize(app, env)
          @app = app
        end

        def call(env)
          config = env[:machine].provider_config          
          connection = env[:vSphere_connection]
          machine = env[:machine]
          
          dc = get_datacenter connection, machine
          template = dc.find_vm config.template_name

          raise Error::VSphereError, :message => I18n.t('errors.missing_template') if template.nil?

          begin
            location = RbVmomi::VIM.VirtualMachineRelocateSpec :pool => get_resource_pool(connection, machine)
            datastore = get_datastore connection, machine
            location[:datastore] = datastore unless datastore.nil?
            
            spec = RbVmomi::VIM.VirtualMachineCloneSpec :location => location, :powerOn => true, :template => false
            
            customization = get_customization_spec_info_by_name connection, machine
            if customization != nil
              spec[:customization] = customization.spec
              machine.config.vm.networks.each do |type, options|
                if type == :private_network
                  env[:ui].info "IP address will be set to #{options[:ip]} for private network when customizing guest"
                  spec[:customization].nicSettingMap[0].adapter.ip.ipAddress = options[:ip]
                end
              end
            end
            
            env[:ui].info I18n.t('vsphere.creating_cloned_vm')
            env[:ui].info " -- Template VM: #{config.template_name}"
            env[:ui].info " -- Name: #{config.name}"

            new_vm = template.CloneVM_Task(:folder => template.parent, :name => config.name, :spec => spec).wait_for_completion
          rescue Exception => e
            puts e.message
            raise Errors::VSphereError, :message => e.message
          end

          #TODO: handle interrupted status in the environment, should the vm be destroyed?

          machine.id = new_vm.config.uuid
          
          # wait for SSH to be available 
          wait_for_ssh env
          
          env[:ui].info I18n.t('vsphere.vm_clone_success')          
            
          @app.call env
        end
      end
    end
  end
end