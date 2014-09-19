require 'vagrant'

module VagrantPlugins
  module VSphere
    module Errors
      class VSphereError < Vagrant::Errors::VagrantError
        error_namespace('vsphere.errors')
      end
    end
  end
end
