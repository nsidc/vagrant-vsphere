require 'vagrant'

module VagrantPlugins
  module VSphere
    class Config < Vagrant.plugin('2', :config)
      attr_accessor host
      attr_accessor user
      attr_accessor password
      attr_accessor data_center_name
      attr_accessor template_name
    end
  end
end