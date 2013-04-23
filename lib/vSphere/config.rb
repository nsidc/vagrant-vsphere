require 'vagrant'

module VagrantPlugins
  module VSphere
    class Config < Vagrant.plugin('2', :config)
      attr_accessor host
      attr_accessor user
      attr_accessor password
      attr_accessor data_center_name
      attr_accessor template_name
      attr_accessor name

      def validate
        errors = _detected_errors

        #TODO: add internationalization with il8n
        errors << 'Configuration must specify a vSphere host' if host.nil?
        errors << 'Configuration must specify a vSphere user' if user.nil?
        errors << 'Configuration must specify a vSphere password' if password.nil?
        errors << 'Configuration must specify a VM name' if name.nil?
        errors<< 'Configuration must specify a template name' if template_name.nil?

        { 'vSphere Provider' => errors }
      end
    end
  end
end