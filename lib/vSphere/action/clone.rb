require 'rbvmomi'
require 'i18n'
require 'vSphere/util/vim_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class Clone
        include Util::VimHelpers

        def initialize(app, _env)
          @app = app
        end

        def call(env)
          machine = env[:machine]
          config = machine.provider_config
          connection = env[:vSphere_connection]
          name = get_name machine, config, env[:root_path]
          dc = get_datacenter connection, machine
          template = dc.find_vm config.template_name
          disk_size_in_gb = config.disk_size.to_i
          fail Errors::VSphereError, :'missing_template' if template.nil?
          vm_base_folder = get_vm_base_folder dc, template, config
          fail Errors::VSphereError, :'invalid_base_path' if vm_base_folder.nil?

          begin
            # Storage DRS does not support vSphere linked clones. http://www.vmware.com/files/pdf/techpaper/vsphere-storage-drs-interoperability.pdf
            ds = get_datastore dc, machine
            fail Errors::VSphereError, :'invalid_configuration_linked_clone_with_sdrs' if config.linked_clone && ds.is_a?(RbVmomi::VIM::StoragePod)

            location = get_location ds, dc, machine, template
            spec = RbVmomi::VIM.VirtualMachineCloneSpec location: location, powerOn: false, template: false
            spec[:config] = RbVmomi::VIM.VirtualMachineConfigSpec
            customization_info = get_customization_spec_info_by_name connection, machine

            spec[:customization] = get_customization_spec(machine, customization_info) unless customization_info.nil?

            env[:ui].info "Setting custom address: #{config.addressType}" unless config.addressType.nil?
            add_custom_address_type(template, spec, config.addressType) unless config.addressType.nil?

            env[:ui].info "Setting custom mac: #{config.mac}" unless config.mac.nil?
            add_custom_mac(template, spec, config.mac) unless config.mac.nil?

            env[:ui].info "Setting custom vlan: #{config.vlan}" unless config.vlan.nil?
            add_custom_vlan(template, dc, spec, config.vlan) unless config.vlan.nil?

            env[:ui].info "Setting custom memory: #{config.memory_mb}" unless config.memory_mb.nil?
            add_custom_memory(spec, config.memory_mb) unless config.memory_mb.nil?

            env[:ui].info "Setting custom cpu count: #{config.cpu_count}" unless config.cpu_count.nil?
            add_custom_cpu(spec, config.cpu_count) unless config.cpu_count.nil?

            env[:ui].info "Setting custom cpu reservation: #{config.cpu_reservation}" unless config.cpu_reservation.nil?
            add_custom_cpu_reservation(spec, config.cpu_reservation) unless config.cpu_reservation.nil?

            env[:ui].info "Setting custom memmory reservation: #{config.mem_reservation}" unless config.mem_reservation.nil?
            add_custom_mem_reservation(spec, config.mem_reservation) unless config.mem_reservation.nil?
            add_custom_extra_config(spec, config.extra_config) unless config.extra_config.empty?
            add_custom_notes(spec, config.notes) unless config.notes.nil?

            env[:ui].info "Setting custom disk size: #{disk_size_in_gb}" if disk_size_in_gb.to_i > 0

            if !config.clone_from_vm && ds.is_a?(RbVmomi::VIM::StoragePod)

              storage_mgr = connection.serviceContent.storageResourceManager
              pod_spec = RbVmomi::VIM.StorageDrsPodSelectionSpec(storagePod: ds)
              # TODO: May want to add option on type?
              storage_spec = RbVmomi::VIM.StoragePlacementSpec(type: 'clone', cloneName: name, folder: vm_base_folder, podSelectionSpec: pod_spec, vm: template, cloneSpec: spec)

              env[:ui].info I18n.t('vsphere.requesting_sdrs_recommendation')
              env[:ui].info " -- DatastoreCluster: #{ds.name}"
              env[:ui].info " -- Template VM: #{template.pretty_path}"
              env[:ui].info " -- Target VM: #{vm_base_folder.pretty_path}/#{name}"

              result = storage_mgr.RecommendDatastores(storageSpec: storage_spec)

              recommendation = result.recommendations[0]
              key = recommendation.key ||= ''
              if key == ''
                fail Errors::VSphereError, :missing_datastore_recommendation
              end

              env[:ui].info I18n.t('vsphere.creating_cloned_vm_sdrs')
              env[:ui].info " -- Storage DRS recommendation: #{recommendation.target.name} #{recommendation.reasonText}"

              apply_sr_result = storage_mgr.ApplyStorageDrsRecommendation_Task(key: [key]).wait_for_completion
              new_vm = apply_sr_result.vm

            else
              env[:ui].info I18n.t('vsphere.creating_cloned_vm')
              env[:ui].info " -- #{config.clone_from_vm ? 'Source' : 'Template'} VM: #{template.pretty_path}"
              env[:ui].info " -- Target VM: #{vm_base_folder.pretty_path}/#{name}"

              new_vm = template.CloneVM_Task(folder: vm_base_folder, name: name, spec: spec).wait_for_completion
              resize_disk(new_vm, disk_size_in_gb) if disk_size_in_gb.to_i > 0
              new_vm.PowerOnVM_Task.wait_for_completion

              config.custom_attributes.each do |k, v|
                env[:ui].info "Setting custom attribute: #{k}=#{v}"
                new_vm.setCustomValue(key: k, value: v)
              end
            end
          rescue Errors::VSphereError
            raise
          rescue StandardError => e
            raise Errors::VSphereError.new, e.message
          end

          # TODO: handle interrupted status in the environment, should the vm be destroyed?

          machine.id = new_vm.config.uuid

          wait_for_sysprep(env, new_vm, connection, 600, 10) if config.wait_for_sysprep && machine.config.vm.guest.eql?(:windows)

          env[:ui].info I18n.t('vsphere.vm_clone_success')

          @app.call env
        end

        private

        def wait_for_sysprep(env, vm, vim_connection, timeout, sleep_time)
          vem = vim_connection.serviceContent.eventManager

          wait = true
          waited_seconds = 0

          env[:ui].info I18n.t('vsphere.wait_sysprep')
          while wait
            events = query_customization_succeeded(vm, vem)

            if events.size > 0
              events.each do |e|
                env[:ui].info e.fullFormattedMessage
              end
              wait = false
            elsif waited_seconds >= timeout
              fail Errors::VSphereError, :'sysprep_timeout'
            else
              sleep(sleep_time)
              waited_seconds += sleep_time
            end
          end
        end

        def query_customization_succeeded(vm, vem)
          vem.QueryEvents(filter:
              RbVmomi::VIM::EventFilterSpec(entity:
              RbVmomi::VIM::EventFilterSpecByEntity(entity: vm, recursion:
              RbVmomi::VIM::EventFilterSpecRecursionOption(:self)), eventTypeId: ['CustomizationSucceeded']))
        end

        def resize_disk(machine, size)
          # get current vm disk
          virtual_disk = machine.config.hardware.device.grep(RbVmomi::VIM::VirtualDisk)[0]
          virtual_disk.capacityInKB = size * 1024 * 1024

          # execute reconfigure task
          new_vm_spec = RbVmomi::VIM.VirtualMachineConfigSpec(
            :deviceChange => [RbVmomi::VIM.VirtualDeviceConfigSpec(
              :device => virtual_disk,
              :operation => RbVmomi::VIM.VirtualDeviceConfigSpecOperation(:edit)
            )]
          )
          task = machine.ReconfigVM_Task(:spec => new_vm_spec)
          task.wait_for_completion
          { 'task_state' => task.info.state }
        end

        def get_customization_spec(machine, spec_info)
          customization_spec = spec_info.spec.clone

          # find all the configured private networks
          private_networks = machine.config.vm.networks.find_all { |n| n[0].eql? :private_network }
          return customization_spec if private_networks.nil?

          # make sure we have enough NIC settings to override with the private network settings
          fail Errors::VSphereError, :'too_many_private_networks' if private_networks.length > customization_spec.nicSettingMap.length

          # assign the private network IP to the NIC
          private_networks.each_index do |idx|
            customization_spec.nicSettingMap[idx].adapter.ip.ipAddress = private_networks[idx][1][:ip]
          end

          customization_spec
        end

        def get_location(datastore, dc, machine, template)
          if machine.provider_config.linked_clone
            # The API for linked clones is quite strange. We can't create a linked
            # straight from any VM. The disks of the VM for which we can create a
            # linked clone need to be read-only and thus VC demands that the VM we
            # are cloning from uses delta-disks. Only then it will allow us to
            # share the base disk.
            #
            # Thus, this code first create a delta disk on top of the base disk for
            # the to-be-cloned VM, if delta disks aren't used already.
            disks = template.config.hardware.device.grep(RbVmomi::VIM::VirtualDisk)
            disks.select { |disk| disk.backing.parent.nil? }.each do |disk|
              spec = {
                deviceChange: [
                  {
                    operation: :remove,
                    device: disk
                  },
                  {
                    operation: :add,
                    fileOperation: :create,
                    device: disk.dup.tap do |new_disk|
                              new_disk.backing = new_disk.backing.dup
                              new_disk.backing.fileName = "[#{disk.backing.datastore.name}]"
                              new_disk.backing.parent = disk.backing
                            end
                  }
                ]
              }
              template.ReconfigVM_Task(spec: spec).wait_for_completion
            end

            location = RbVmomi::VIM.VirtualMachineRelocateSpec(diskMoveType: :moveChildMostDiskBacking)
          elsif datastore.is_a? RbVmomi::VIM::StoragePod
            location = RbVmomi::VIM.VirtualMachineRelocateSpec
          else
            location = RbVmomi::VIM.VirtualMachineRelocateSpec

            location[:datastore] = datastore unless datastore.nil?
          end
          location[:pool] = get_resource_pool(dc, machine) unless machine.provider_config.clone_from_vm
          location
        end

        def get_name(machine, config, root_path)
          return config.name unless config.name.nil?

          prefix = "#{root_path.basename}_#{machine.name}"
          prefix.gsub!(/[^-a-z0-9_\.]/i, '')
          # milliseconds + random number suffix to allow for simultaneous `vagrant up` of the same box in different dirs
          prefix + "_#{(Time.now.to_f * 1000.0).to_i}_#{rand(100_000)}"
        end

        def get_vm_base_folder(dc, template, config)
          if config.vm_base_path.nil?
            template.parent
          else
            dc.vmFolder.traverse(config.vm_base_path, RbVmomi::VIM::Folder, true)
          end
        end

        def modify_network_card(template, spec)
          spec[:config][:deviceChange] ||= []
          @card ||= template.config.hardware.device.grep(RbVmomi::VIM::VirtualEthernetCard).first

          fail Errors::VSphereError, :missing_network_card if @card.nil?

          yield(@card)

          dev_spec = RbVmomi::VIM.VirtualDeviceConfigSpec(device: @card, operation: 'edit')
          spec[:config][:deviceChange].push dev_spec
          spec[:config][:deviceChange].uniq!
        end

        def add_custom_address_type(template, spec, addressType)
          spec[:config][:deviceChange] = []
          config = template.config
          card = config.hardware.device.grep(RbVmomi::VIM::VirtualEthernetCard).first || fail(Errors::VSphereError, :missing_network_card)
          card.addressType = addressType
          card_spec = { :deviceChange => [{ :operation => :edit, :device => card }] }
          template.ReconfigVM_Task(:spec => card_spec).wait_for_completion
        end

        def add_custom_mac(template, spec, mac)
          modify_network_card(template, spec) do |card|
            card.macAddress = mac
          end
        end

        def add_custom_vlan(template, dc, spec, vlan)
          network = get_network_by_name(dc, vlan)

          modify_network_card(template, spec) do |card|
            begin
              switch_port = RbVmomi::VIM.DistributedVirtualSwitchPortConnection(switchUuid: network.config.distributedVirtualSwitch.uuid, portgroupKey: network.key)
              card.backing = RbVmomi::VIM::VirtualEthernetCardDistributedVirtualPortBackingInfo(port: switch_port)
            rescue
              # not connected to a distibuted switch?
              card.backing = RbVmomi::VIM::VirtualEthernetCardNetworkBackingInfo(network: network, deviceName: network.name)
            end
          end
        end

        def add_custom_memory(spec, memory_mb)
          spec[:config][:memoryMB] = Integer(memory_mb)
        end

        def add_custom_cpu(spec, cpu_count)
          spec[:config][:numCPUs] = Integer(cpu_count)
        end

        def add_custom_cpu_reservation(spec, cpu_reservation)
          spec[:config][:cpuAllocation] = RbVmomi::VIM.ResourceAllocationInfo(reservation: cpu_reservation)
        end

        def add_custom_mem_reservation(spec, mem_reservation)
          spec[:config][:memoryAllocation] = RbVmomi::VIM.ResourceAllocationInfo(reservation: mem_reservation)
        end

        def add_custom_extra_config(spec, extra_config = {})
          return if extra_config.empty?

          # extraConfig must be an array of hashes with `key` and `value`
          # entries.
          spec[:config][:extraConfig] = extra_config.map { |k, v| { 'key' => k, 'value' => v } }
        end

        def add_custom_notes(spec, notes)
          spec[:config][:annotation] = notes
        end
      end
    end
  end
end
