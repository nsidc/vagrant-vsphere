require 'rbvmomi'

module VagrantPlugins
  module VSphere
    module Util
      module VimHelpers
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
      end
    end
  end
end
