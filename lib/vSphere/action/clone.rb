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
            if not config.clone_from_vm
              location = RbVmomi::VIM.VirtualMachineRelocateSpec :pool => get_resource_pool(connection, machine)
            else
              location = RbVmomi::VIM.VirtualMachineRelocateSpec
            end
            datastore = get_datastore connection, machine
            location[:datastore] = datastore unless datastore.nil?
            
            spec = RbVmomi::VIM.VirtualMachineCloneSpec :location => location, :powerOn => true, :template => false
            
            customization = get_customization_spec_info_by_name connection, machine
            spec[:customization] = configure_networks(customization.spec, machine) unless customization.nil?
            
            env[:ui].info I18n.t('vsphere.creating_cloned_vm')
            env[:ui].info " -- #{config.clone_from_vm ? "Source" : "Template"} VM: #{config.template_name}"
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
        
        private
        
        def configure_networks(spec, machine)
          customization_spec = spec.clone
          
          # find all the configured private networks
          private_networks = machine.config.vm.networks.find_all { |n| n[0].eql? :private_network }
          return customization_spec if private_networks.nil?
          
          # make sure we have enough NIC settings to override with the private network settings
          raise Error::VSphereError, :message => I18n.t('errors.too_many_private_networks') if private_networks.length > customization_spec.nicSettingMap.length
          
          # assign the private network IP to the NIC
          private_networks.each_index do |idx|
            customization_spec.nicSettingMap[idx].adapter.ip.ipAddress = private_networks[idx][1][:ip]  
          end
          
          customization_spec
        end
      end
    end
  end
end
