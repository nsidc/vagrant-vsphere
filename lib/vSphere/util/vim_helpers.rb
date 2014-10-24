require 'rbvmomi'

module VagrantPlugins
  module VSphere
    module Util
      module VimHelpers
        def get_datacenter(connection, machine)
          connection.serviceInstance.find_datacenter(machine.provider_config.data_center_name) or fail Errors::VSphereError, :missing_datacenter
        end

        def get_vm_by_uuid(connection, machine)
          get_datacenter(connection, machine).vmFolder.findByUuid machine.id
        end

        def get_resource_pool(connection, machine)
          cr = get_compute_resource(connection, machine)
          rp = cr.resourcePool
          if !(machine.provider_config.resource_pool_name.nil?)
            rp = cr.resourcePool.find(machine.provider_config.resource_pool_name) or  fail Errors::VSphereError, :missing_resource_pool
          end
          rp
        end

        def get_compute_resource(connection, machine)
          datacenter = get_datacenter(connection, machine);
          cr = find_clustercompute_or_compute_resource(datacenter, machine.provider_config.compute_resource_name) or fail Errors::VSphereError, :missing_compute_resource
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
          
          p = es.inject(datacenter.hostFolder) do |f,e|
            f.find(e, RbVmomi::VIM::Folder) || return
          end

          begin
            if x = p.find(final, RbVmomi::VIM::ComputeResource)
              x
            elsif x = p.find(final, RbVmomi::VIM::ClusterComputeResource)
              x
            else
              nil
            end
          rescue Exception => e
# When looking for the ClusterComputeResource there seems to be some parser error in RbVmomi Folder.find, try this instead
            x = p.childEntity.find { |x| x.name == final }
            if x.is_a? RbVmomi::VIM::ClusterComputeResource or x.is_a? RbVmomi::VIM::ComputeResource
              x
            else
              puts "ex unknonw type " + x.to_json
              nil
            end
          end

        end

        def get_customization_spec_info_by_name(connection, machine)
          name = machine.provider_config.customization_spec_name
          return if name.nil? || name.empty?

          manager = connection.serviceContent.customizationSpecManager or fail Errors::VSphereError, :null_configuration_spec_manager if manager.nil?
          spec = manager.GetCustomizationSpec(:name => name) or fail Errors::VSphereError, :missing_configuration_spec if spec.nil?
        end

        def get_datastore(connection, machine)
          name = machine.provider_config.data_store_name
          return if name.nil? || name.empty?

          get_datacenter(connection, machine).find_datastore name or fail Errors::VSphereError, :missing_datastore
        end

        def get_network_by_name(dc, name)
          dc.network.find { |f| f.name == name } or fail Errors::VSphereError, :missing_vlan
        end
      end
    end
  end
end
