require 'i18n'

module VagrantPlugins
  module VSphere
    module Action
      class MessageAlreadyCreated
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:ui].info I18n.t('vsphere.vm_already_created')
          @app.call(env)
        end
      end
    end
  end
end
