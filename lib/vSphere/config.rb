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
        errors << I18n.t('config.host') if host.nil?
        errors <<  I18n.t('config.user') if user.nil?
        errors <<  I18n.t('config.password') if password.nil?
        errors <<  I18n.t('config.name') if name.nil?
        errors<<  I18n.t('config.template') if template_name.nil?

        { 'vSphere Provider' => errors }
      end
    end
  end
end