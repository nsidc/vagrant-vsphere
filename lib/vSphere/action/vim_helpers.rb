require 'rbvmomi'

module VagrantPlugins
  module VSphere
    module Action
      module VimHelpers
        def get_datacenter(connection, config)
          connection.serviceInstance.find_datacenter(config.data_center_name) or fail Errors::VSphereError, :message => 'Configured data center not found'
        end

        def get_vm_by_uuid(connection, machine)
          get_datacenter(connection, machine.provider_config).vmFolder.findByUuid machine.id
        end
      end
    end
  end
end