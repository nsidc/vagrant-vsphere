require 'rbvmomi'
require 'i18n'

module VagrantPlugins
  module VSphere
    module Action
      class PowerOn
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info I18n.t('vsphere.power_on_vm')
          env[:machine].provider.driver.power_on_vm

          @app.call env
        end
      end
    end
  end
end
