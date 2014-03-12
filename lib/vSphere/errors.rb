require 'vagrant'

module VagrantPlugins
  module VSphere
    module Errors
      class VSphereError < Vagrant::Errors::VagrantError
        error_namespace('vsphere.errors')
      end
      class RsyncError < VSphereError
        error_key(:rsync_error)
      end
    end
  end
end
