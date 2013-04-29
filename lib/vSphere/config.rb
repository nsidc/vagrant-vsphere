require 'vagrant'

module VagrantPlugins
  module VSphere
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :host
      attr_accessor :insecure
      attr_accessor :user
      attr_accessor :password
      attr_accessor :data_center_name
      attr_accessor :compute_resource_name
      attr_accessor :resource_pool_name
      attr_accessor :template_name
      attr_accessor :name

      def validate(machine)
        errors = _detected_errors

        #TODO: add blank?
        errors << I18n.t('config.host') if host.nil?
        errors <<  I18n.t('config.user') if user.nil?
        errors <<  I18n.t('config.password') if password.nil?
        errors <<  I18n.t('config.name') if name.nil?
        errors<<  I18n.t('config.template') if template_name.nil?
        errors << I18n.t('config.compute_resource') if compute_resource_name.nil?
        errors << I18n.t('config.resource_pool') if resource_pool_name.nil?

        { 'vSphere Provider' => errors }
      end
    end
  end
end