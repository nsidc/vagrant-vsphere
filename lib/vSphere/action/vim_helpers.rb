require 'rbvmomi'

module VagrantPlugins
  module VSphere
    module Action
      module VimHelpers
        def get_datacenter(connection, config)
          connection.serviceInstance.find_datacenter(config.data_center_name) or fail Errors::VSphereError, :message => 'Configured data center not found'
        end
      end
    end
  end
end