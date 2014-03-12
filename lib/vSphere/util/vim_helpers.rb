require 'rbvmomi'

module VagrantPlugins
  module VSphere
    module Util
      module VimHelpers
        def get_datacenter(connection, machine)
          connection.serviceInstance.find_datacenter(machine.provider_config.data_center_name) or fail Errors::VSphereError, :message => I18n.t('errors.missing_datacenter')
        end

        def get_vm_by_uuid(connection, machine)
          get_datacenter(connection, machine).vmFolder.findByUuid machine.id
        end

        def get_resource_pool(connection, machine)
          dc = get_datacenter(connection, machine)
          pool_name = machine.provider_config.resource_pool_name
          maybe_resource_pool = dc.hostFolder
          
          pool_candidates = pool_name.split('/')
          pool_candidates.each do |pool_candidate|
            if pool_candidate != ''
              if maybe_resource_pool.is_a? RbVmomi::VIM::Folder
                maybe_resource_pool = maybe_resource_pool.childEntity.find { |f| f.name == pool_candidate } or 
                  fail Errors::VSphereError, :message => I18n.t('errors.missing_resource_pool')
              elsif maybe_resource_pool.is_a? RbVmomi::VIM::ClusterComputeResource or maybe_resource_pool.is_a? RbVmomi::VIM::ComputeResource
                maybe_resource_pool = maybe_resource_pool.resourcePool.resourcePool.find { |f| f.name == pool_candidate } or 
                  fail Errors::VSphereError, :message => I18n.t('errors.missing_resource_pool')
              elsif maybe_resource_pool.is_a? RbVmomi::VIM::ResourcePool
                maybe_resource_pool = maybe_resource_pool.resourcePool.find { |f| f.name == pool_candidate } or 
                  fail Errors::VSphereError, :message => I18n.t('errors.missing_resource_pool')
              else
                fail Errors::VSphereError, :message => I18n.t('errors.missing_resource_pool')
              end
            end
          end

          resource_pool = maybe_resource_pool.resourcePool if not maybe_resource_pool.is_a?(RbVmomi::VIM::ResourcePool) and maybe_resource_pool.respond_to?(:resourcePool)
          resource_pool
        end
        
        def get_customization_spec_info_by_name(connection, machine)
          name = machine.provider_config.customization_spec_name
          return if name.nil? || name.empty?
          
          manager = connection.serviceContent.customizationSpecManager or fail Errors::VSphereError, :message => I18n.t('errors.null_configuration_spec_manager') if manager.nil?            
          spec = manager.GetCustomizationSpec(:name => name) or fail Errors::VSphereError, :message => I18n.t('errors.missing_configuration_spec') if spec.nil?
        end
        
        def get_datastore(connection, machine)
          name = machine.provider_config.data_store_name
          return if name.nil? || name.empty?
          
          get_datacenter(connection, machine).find_datastore name or fail Errors::VSphereError, :message => I18n.t('errors.missing_datastore')
        end
      end
    end
  end
end