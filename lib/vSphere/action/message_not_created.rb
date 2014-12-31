require 'i18n'

module VagrantPlugins
  module VSphere
    module Action
      class MessageNotCreated
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info I18n.t('vsphere.vm_not_created')
          @app.call(env)
        end
      end
    end
  end
end
