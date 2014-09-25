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
          machine = env[:machine]
          config = machine.provider_config
          connection = env[:vSphere_connection]
          name = get_name machine, config, env[:root_path]
          dc = get_datacenter connection, machine
          template = dc.find_vm config.template_name
          raise Errors::VSphereError, :'missing_template' if template.nil?
          vm_base_folder = get_vm_base_folder dc, template, config
          raise Errors::VSphereError, :'invalid_base_path' if vm_base_folder.nil?

          begin
            location = get_location connection, machine, config, template
            spec = RbVmomi::VIM.VirtualMachineCloneSpec :location => location, :powerOn => true, :template => false
            spec[:config] = RbVmomi::VIM.VirtualMachineConfigSpec
            customization_info = get_customization_spec_info_by_name connection, machine

            spec[:customization] = get_customization_spec(machine, customization_info) unless customization_info.nil?
            add_custom_vlan(template, dc, spec, config.vlan) unless config.vlan.nil?
            add_custom_memory(spec, config.memory_mb) unless config.memory_mb.nil?

            env[:ui].info I18n.t('vsphere.creating_cloned_vm')
            env[:ui].info " -- #{config.clone_from_vm ? "Source" : "Template"} VM: #{template.pretty_path}"
            env[:ui].info " -- Target VM: #{vm_base_folder.pretty_path}/#{name}"

            new_vm = template.CloneVM_Task(:folder => vm_base_folder, :name => name, :spec => spec).wait_for_completion
          rescue Errors::VSphereError => e
            raise
          rescue Exception => e
            raise Errors::VSphereError.new, e.message
          end

          #TODO: handle interrupted status in the environment, should the vm be destroyed?

          machine.id = new_vm.config.uuid

          # wait for SSH to be available
          wait_for_ssh env

          env[:ui].info I18n.t('vsphere.vm_clone_success')

          @app.call env
        end

        private

        def get_customization_spec(machine, spec_info)
          customization_spec = spec_info.spec.clone

          # find all the configured private networks
          private_networks = machine.config.vm.networks.find_all { |n| n[0].eql? :private_network }
          return customization_spec if private_networks.nil?

          # make sure we have enough NIC settings to override with the private network settings
          raise Errors::VSphereError, :'too_many_private_networks' if private_networks.length > customization_spec.nicSettingMap.length

          # assign the private network IP to the NIC
          private_networks.each_index do |idx|
            customization_spec.nicSettingMap[idx].adapter.ip.ipAddress = private_networks[idx][1][:ip]
          end

          customization_spec
        end

        def get_location(connection, machine, config, template)
          if config.linked_clone
            # The API for linked clones is quite strange. We can't create a linked
            # straight from any VM. The disks of the VM for which we can create a
            # linked clone need to be read-only and thus VC demands that the VM we
            # are cloning from uses delta-disks. Only then it will allow us to
            # share the base disk.
            #
            # Thus, this code first create a delta disk on top of the base disk for
            # the to-be-cloned VM, if delta disks aren't used already.
            disks = template.config.hardware.device.grep(RbVmomi::VIM::VirtualDisk)
            disks.select { |disk| disk.backing.parent == nil }.each do |disk|
              spec = {
                  :deviceChange => [
                      {
                          :operation => :remove,
                          :device => disk
                      },
                      {
                          :operation => :add,
                          :fileOperation => :create,
                          :device => disk.dup.tap { |new_disk|
                            new_disk.backing = new_disk.backing.dup
                            new_disk.backing.fileName = "[#{disk.backing.datastore.name}]"
                            new_disk.backing.parent = disk.backing
                          },
                      }
                  ]
              }
              template.ReconfigVM_Task(:spec => spec).wait_for_completion
            end

            location = RbVmomi::VIM.VirtualMachineRelocateSpec(:diskMoveType => :moveChildMostDiskBacking)
          else
            location = RbVmomi::VIM.VirtualMachineRelocateSpec

            datastore = get_datastore connection, machine
            location[:datastore] = datastore unless datastore.nil?
          end
          location[:pool] = get_resource_pool(connection, machine) unless config.clone_from_vm
          location
        end

        def get_name(machine, config, root_path)
          return config.name unless config.name.nil?

          prefix = "#{root_path.basename.to_s}_#{machine.name}"
          prefix.gsub!(/[^-a-z0-9_\.]/i, "")
          # milliseconds + random number suffix to allow for simultaneous `vagrant up` of the same box in different dirs
          prefix + "_#{(Time.now.to_f * 1000.0).to_i}_#{rand(100000)}"
        end

        def get_vm_base_folder(dc, template, config)
          if config.vm_base_path.nil?
            template.parent
          else
            dc.vmFolder.traverse(config.vm_base_path, RbVmomi::VIM::Folder, create = true)
          end
        end

        def add_custom_vlan(template, dc, spec, vlan)
          spec[:config][:deviceChange] = []
          network = get_network_by_name(dc, vlan)
          config = template.config
          card = config.hardware.device.grep(RbVmomi::VIM::VirtualEthernetCard).first or fail Errors::VSphereError, :missing_network_card
          begin
            switch_port = RbVmomi::VIM.DistributedVirtualSwitchPortConnection(:switchUuid => network.config.distributedVirtualSwitch.uuid, :portgroupKey => network.key)
            card.backing.port = switch_port
          rescue
            # not connected to a distibuted switch?
            card.backing.deviceName = network.name
          end
          dev_spec = RbVmomi::VIM.VirtualDeviceConfigSpec(:device => card, :operation => "edit")
          spec[:config][:deviceChange].push dev_spec
        end

        def add_custom_memory(spec, memory_mb)
          spec[:config][:memoryMB] = Integer(memory_mb)
        end
      end
    end
  end
end
