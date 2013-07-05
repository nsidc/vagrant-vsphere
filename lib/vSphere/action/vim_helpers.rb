require 'rbvmomi'

module VagrantPlugins
  module VSphere
    module Action
      module VimHelpers
        def get_datacenter(connection, machine)
          connection.serviceInstance.find_datacenter(machine.provider_config.data_center_name) or fail Errors::VSphereError, :message => I18n.t('errors.missing_datacenter')
        end

        def get_vm_by_uuid(connection, machine)
          get_datacenter(connection, machine).vmFolder.findByUuid machine.id
        end

        def get_resource_pool(connection, machine)
          cr = get_datacenter(connection, machine).find_compute_resource(machine.provider_config.compute_resource_name) or fail Errors::VSphereError, :message => I18n.t('errors.missing_compute_resource')
          cr.resourcePool.find(machine.provider_config.resource_pool_name) or fail Errors::VSphereError, :message => I18n.t('errors.missing_resource_pool')
        end
      end
    end
  end
end