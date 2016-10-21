require 'log4r'
require 'rbvmomi'

module VagrantPlugins
  	module VSphere
			module VmState
				POWERED_ON = 'poweredOn'
				POWERED_OFF = 'poweredOff'
				SUSPENDED = 'suspended'
			end

    	class Driver
				attr_reader :logger
				attr_reader :machine

				def initialize(machine)
					@logger = Log4r::Logger.new("vagrant::provider::vsphere::driver")
					@machine = machine
				end

				def connection
					raise "connection be called from a code block!" if !block_given?

					begin
						config = @machine.provider_config

						current_connection = RbVmomi::VIM.connect host: config.host,
																											 user: config.user, password: config.password,
																											 insecure: config.insecure, proxyHost: config.proxy_host,
																											 proxyPort: config.proxy_port

						yield current_connection
					rescue
						raise
					ensure
						current_connection.close if current_connection
					end
				end

				def ssh_info
					return nil if @machine.id.nil?

					connection do |conn|
						vm = get_vm_by_uuid conn, @machine
						return nil if vm.nil?

						ip_address = filter_guest_nic(vm, @machine)
						return nil if ip_address.nil? || ip_address.empty?
						{
								host: ip_address,
								port: 22
						}
					end
				end

				def state
					return :not_created if @machine.id.nil?

					connection do |conn|
						vm = get_vm_by_uuid conn, @machine

						return :not_created if vm.nil?

						if powered_on?
							:running
						else
							# If the VM is powered off or suspended, we consider it to be powered off. A power on command will either turn on or resume the VM
							:poweroff
						end
					end
				end

				def power_on_vm
					return nil if @machine.id.nil?

					connection do |conn|
						vm = get_vm_by_uuid conn, @machine
						@logger.info("Start powering on vm #{@machine.id}")
						vm.PowerOnVM_Task.wait_for_completion
						@logger.info("Finished powering on vm #{@machine.id}")
					end
				end

				def power_off_vm
					return nil if @machine.id.nil?

					connection do |conn|
						vm = get_vm_by_uuid conn, @machine
						@logger.info("Start powering off vm #{@machine.id}")
						vm.PowerOffVM_Task.wait_for_completion
						@logger.info("Finished powering off vm #{@machine.id}")
					end
				end

				def get_vm_state
					return nil if @machine.id.nil?

					connection do |conn|
						vm = get_vm_by_uuid conn, @machine
						vm.runtime.powerState
					end
				end

				def powered_on?
					return nil if @machine.id.nil?
					connection do |conn|
						vm = get_vm_by_uuid conn, @machine
						vm.runtime.powerState.eql?(VmState::POWERED_ON)
					end
				end

				def powered_off?
					return nil if @machine.id.nil?
					connection do |conn|
						vm = get_vm_by_uuid conn, @machine
						vm.runtime.powerState.eql?(VmState::POWERED_OFF)
					end
				end

				def suspended?
					return nil if @machine.id.nil?
					connection do |conn|
						vm = get_vm_by_uuid conn, @machine
						vm.runtime.powerState.eql?(VmState::SUSPENDED)
					end
				end

				def clone(root_path)
					config = machine.provider_config
					connection do |conn|
						name = get_name @machine, config, root_path
						dc = get_datacenter conn, @machine
						template = dc.find_vm config.template_name
						fail Errors::VSphereError, :'missing_template' if template.nil?
						vm_base_folder = get_vm_base_folder dc, template, config
						fail Errors::VSphereError, :'invalid_base_path' if vm_base_folder.nil?

						begin
							# Storage DRS does not support vSphere linked clones. http://www.vmware.com/files/pdf/techpaper/vsphere-storage-drs-interoperability.pdf
							ds = get_datastore dc, @machine
							fail Errors::VSphereError, :'invalid_configuration_linked_clone_with_sdrs' if config.linked_clone && ds.is_a?(RbVmomi::VIM::StoragePod)

							location = get_location ds, dc, @machine, template

							spec = RbVmomi::VIM.VirtualMachineCloneSpec location: location, powerOn: true, template: false
							spec[:config] = RbVmomi::VIM.VirtualMachineConfigSpec
							customization_info = get_customization_spec_info_by_name conn, @machine
							spec[:customization] = get_customization_spec(@machine, customization_info) unless customization_info.nil?
							add_custom_address_type(template, spec, config.addressType) unless config.addressType.nil?
							add_custom_mac(template, spec, config.mac) unless config.mac.nil?
							add_custom_vlan(template, dc, spec, config.vlan) unless config.vlan.nil?
							add_custom_memory(spec, config.memory_mb) unless config.memory_mb.nil?
							add_custom_cpu(spec, config.cpu_count) unless config.cpu_count.nil?
							add_custom_cpu_reservation(spec, config.cpu_reservation) unless config.cpu_reservation.nil?
							add_custom_mem_reservation(spec, config.mem_reservation) unless config.mem_reservation.nil?
							add_custom_extra_config(spec, config.extra_config) unless config.extra_config.empty?
							add_custom_notes(spec, config.notes) unless config.notes.nil?

							if !config.clone_from_vm && ds.is_a?(RbVmomi::VIM::StoragePod)

								storage_mgr = conn.serviceContent.storageResourceManager
								pod_spec = RbVmomi::VIM.StorageDrsPodSelectionSpec(storagePod: ds)
								# TODO: May want to add option on type?
								storage_spec = RbVmomi::VIM.StoragePlacementSpec(type: 'clone', cloneName: name, folder: vm_base_folder, podSelectionSpec: pod_spec, vm: template, cloneSpec: spec)

								@logger.info(I18n.t('vsphere.requesting_sdrs_recommendation'))
								@logger.info(" -- DatastoreCluster: #{ds.name}")
								@logger.info(" -- Template VM: #{template.pretty_path}")
								@logger.info(" -- Target VM: #{vm_base_folder.pretty_path}/#{name}")

								result = storage_mgr.RecommendDatastores(storageSpec: storage_spec)

								recommendation = result.recommendations[0]
								key = recommendation.key ||= ''
								if key == ''
									fail Errors::VSphereError, :missing_datastore_recommendation
								end

								@logger.info(I18n.t('vsphere.creating_cloned_vm_sdrs'))
								@logger.info(" -- Storage DRS recommendation: #{recommendation.target.name} #{recommendation.reasonText}")

								@logger.info("Start cloning vm #{@machine.id}")
								task = storage_mgr.ApplyStorageDrsRecommendation_Task(key: [key])

								apply_sr_result = nil
								if block_given?
									apply_sr_result = task.wait_for_progress do |progress|
										yield progress unless progress.nil?
									end
								else
									apply_sr_result = task.wait_for_completion
								end
								@logger.info("Finished cloning vm #{@machine.id}")

								new_vm = apply_sr_result.vm
							else
								@logger.info(I18n.t('vsphere.creating_cloned_vm'))
								@logger.info(" -- #{config.clone_from_vm ? 'Source' : 'Template'} VM: #{template.pretty_path}")
								@logger.info(" -- Target VM: #{vm_base_folder.pretty_path}/#{name}")

								@logger.info("Start cloning vm #{@machine.id}")
								task = template.CloneVM_Task(folder: vm_base_folder, name: name, spec: spec)
								new_vm = nil
								if block_given?
									new_vm = task.wait_for_progress do |progress|
										yield progress unless progress.nil?
									end
								else
									new_vm = task.wait_for_completion
								end
								@logger.info("Finished cloning vm #{@machine.id}")

								config.custom_attributes.each do |k, v|
									new_vm.setCustomValue(key: k, value: v)
								end
							end
						rescue Errors::VSphereError
							raise
						rescue StandardError => e
							raise Errors::VSphereError.new, e.message
						end

						# TODO: handle interrupted status in the environment, should the vm be destroyed?
						@machine.id = new_vm.config.uuid
					end
				end

				def destroy
					return nil if @machine.id.nil?
					return nil unless is_created

					connection do |conn|
						vm = get_vm_by_uuid conn, @machine
						@logger.info("Start destroying vm #{@machine.id}")
						task = vm.Destroy_Task
						if block_given?
							task.wait_for_progress do |progress|
								yield progress unless progress.nil?
							end
						else
							task.wait_for_completion
						end
						@logger.info("Finished destroying vm #{@machine.id}")
					end

					@machine.id = nil
				end

				def is_created
					return false if @machine.id.nil?

					connection do |conn|
						vm = get_vm_by_uuid conn, @machine
						return false if vm.nil?
					end

					true
				end

				def is_running
					state == :running
				end

				def snapshot_list
					return nil if @machine.id.nil?

					connection do |conn|
						vm = get_vm_by_uuid conn, @machine
						@logger.info("Start destroying vm #{@machine.id}")
						snapshots = enumerate_snapshots(vm).map(&:name)
						@logger.info("Finished destroying vm #{@machine.id}")
						return snapshots
					end
				end

				def delete_snapshot(snapshot_name)
					return nil if @machine.id.nil?

					connection do |conn|
						vm = get_vm_by_uuid conn, @machine

						snapshot = enumerate_snapshots(vm).find { |s| s.name == snapshot_name }

						# No snapshot matching "name"
						return nil if snapshot.nil?

						task = snapshot.snapshot.RemoveSnapshot_Task(removeChildren: false)

						@logger.info("Start deleting snapshot #{snapshot_name} on vm #{@machine.id}")
						if block_given?
							task.wait_for_progress do |progress|
								yield progress unless progress.nil?
							end
						else
							task.wait_for_completion
						end
						@logger.info("Finished deleting snapshot #{snapshot_name} on vm #{@machine.id}")
					end
				end

				def restore_snapshot(snapshot_name)
					return nil if @machine.id.nil?

					connection do |conn|
						vm = get_vm_by_uuid conn, @machine

						snapshot = enumerate_snapshots(vm).find { |s| s.name == snapshot_name }

						# No snapshot matching "name"
						return nil if snapshot.nil?

						task = snapshot.snapshot.RevertToSnapshot_Task(suppressPowerOn: true)

						@logger.info("Start restoring snapshot #{snapshot_name} on vm #{@machine.id}")
						if block_given?
							task.wait_for_progress do |progress|
								yield progress unless progress.nil?
							end
						else
							task.wait_for_completion
						end
						@logger.info("Finished restoring snapshot #{snapshot_name} on vm #{@machine.id}")
					end
				end

				def create_snapshot(snapshot_name)
					return nil if @machine.id.nil?

					connection do |conn|
						vm = get_vm_by_uuid conn, @machine

						task = vm.CreateSnapshot_Task(
								name: name,
								memory: false,
								quiesce: false)

						@logger.info("Start creating snapshot #{snapshot_name} on vm #{@machine.id}")

						if block_given?
							task.wait_for_progress do |progress|
								yield progress unless progress.nil?
							end
						else
							task.wait_for_completion
						end

						@logger.info("Finished creating snapshot #{snapshot_name} on vm #{@machine.id}")
					end
				end

				private

				# Enumerate VM snapshot tree
				#
				# This method returns an enumerator that performs a depth-first walk
				# of the VM snapshot grap and yields each VirtualMachineSnapshotTree
				# node.
				#
				# @param vm [RbVmomi::VIM::VirtualMachine]
				#
				# @return [Enumerator<RbVmomi::VIM::VirtualMachineSnapshotTree>]
				def enumerate_snapshots(vm)
					snapshot_info = vm.snapshot

					if snapshot_info.nil?
						snapshot_root = []
					else
						snapshot_root = snapshot_info.rootSnapshotList
					end

					recursor = lambda do |snapshot_list|
						Enumerator.new do |yielder|
							snapshot_list.each do |s|
								# Yield the current VirtualMachineSnapshotTree object
								yielder.yield s

								# Recurse into child VirtualMachineSnapshotTree objects
								children = recursor.call(s.childSnapshotList)
								loop do
									yielder.yield children.next
								end
							end
						end
					end

					recursor.call(snapshot_root)
				end

				def filter_guest_nic(vm, machine)
					return vm.guest.ipAddress unless machine.provider_config.real_nic_ip
					ip_addresses = vm.guest.net.select { |g| g.deviceConfigId > 0 }.map { |g| g.ipAddress[0] }
					fail Errors::VSphereError.new, :'multiple_interface_with_real_nic_ip_set' if ip_addresses.size > 1
					ip_addresses.first
				end

				def get_datacenter(connection, machine)
					connection.serviceInstance.find_datacenter(machine.provider_config.data_center_name) || fail(Errors::VSphereError, :missing_datacenter)
				end

				def get_vm_by_uuid(connection, machine)
					get_datacenter(connection, machine).vmFolder.findByUuid machine.id
				end

				def get_resource_pool(datacenter, machine)
					rp = get_compute_resource(datacenter, machine)

					resource_pool_name = machine.provider_config.resource_pool_name || ''

					entity_array = resource_pool_name.split('/')
					entity_array.each do |entity_array_item|
						next if entity_array_item.empty?
						if rp.is_a? RbVmomi::VIM::Folder
							rp = rp.childEntity.find { |f| f.name == entity_array_item } || fail(Errors::VSphereError, :missing_resource_pool)
						elsif rp.is_a? RbVmomi::VIM::ClusterComputeResource
							rp = rp.resourcePool.resourcePool.find { |f| f.name == entity_array_item } || fail(Errors::VSphereError, :missing_resource_pool)
						elsif rp.is_a? RbVmomi::VIM::ResourcePool
							rp = rp.resourcePool.find { |f| f.name == entity_array_item } || fail(Errors::VSphereError, :missing_resource_pool)
						elsif rp.is_a? RbVmomi::VIM::ComputeResource
							rp = rp.resourcePool.find(resource_pool_name) || fail(Errors::VSphereError, :missing_resource_pool)
						else
							fail Errors::VSphereError, :missing_resource_pool
						end
					end
					rp = rp.resourcePool if !rp.is_a?(RbVmomi::VIM::ResourcePool) && rp.respond_to?(:resourcePool)
					rp
				end

				def get_compute_resource(datacenter, machine)
					cr = find_clustercompute_or_compute_resource(datacenter, machine.provider_config.compute_resource_name)
					fail Errors::VSphereError, :missing_compute_resource if cr.nil?
					cr
				end

				def find_clustercompute_or_compute_resource(datacenter, path)
					if path.is_a? String
						es = path.split('/').reject(&:empty?)
					elsif path.is_a? Enumerable
						es = path
					else
						fail "unexpected path class #{path.class}"
					end
					return datacenter.hostFolder if es.empty?
					final = es.pop

					p = es.inject(datacenter.hostFolder) do |f, e|
						f.find(e, RbVmomi::VIM::Folder) || return
					end

					begin
						if (x = p.find(final, RbVmomi::VIM::ComputeResource))
							x
						elsif (x = p.find(final, RbVmomi::VIM::ClusterComputeResource))
							x
						end
					rescue Exception
						# When looking for the ClusterComputeResource there seems to be some parser error in RbVmomi Folder.find, try this instead
						x = p.childEntity.find { |x2| x2.name == final }
						if x.is_a?(RbVmomi::VIM::ClusterComputeResource) || x.is_a?(RbVmomi::VIM::ComputeResource)
							x
						else
							puts 'ex unknown type ' + x.to_json
							nil
						end
					end
				end

				def get_customization_spec_info_by_name(connection, machine)
					name = machine.provider_config.customization_spec_name
					return if name.nil? || name.empty?

					manager = connection.serviceContent.customizationSpecManager
					fail Errors::VSphereError, :null_configuration_spec_manager if manager.nil?

					spec = manager.GetCustomizationSpec(name: name)
					fail Errors::VSphereError, :missing_configuration_spec if spec.nil?

					spec
				end

				def get_datastore(datacenter, machine)
					name = machine.provider_config.data_store_name
					return if name.nil? || name.empty?

					# find_datastore uses folder datastore that only lists Datastore and not StoragePod, if not found also try datastoreFolder which contains StoragePod(s)
					datacenter.find_datastore(name) || datacenter.datastoreFolder.traverse(name) || fail(Errors::VSphereError, :missing_datastore)
				end

				def get_network_by_name(dc, name)
					dc.network.find { |f| f.name == name } || fail(Errors::VSphereError, :missing_vlan)
				end

				#Cloning
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