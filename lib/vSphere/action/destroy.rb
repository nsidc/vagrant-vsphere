require 'rbvmomi'
require 'i18n'

module VagrantPlugins
  module VSphere
    module Action
      class Destroy
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          destroy_vm env
          env[:machine].id = nil

          @app.call env
        end

        private

        def destroy_vm(env)
          begin
            env[:ui].info I18n.t('vsphere.destroy_vm')

            env[:machine].provider.driver.destroy do |progress|
              env[:ui].clear_line
              env[:ui].report_progress(progress, 100, false)
            end
          rescue Errors::VSphereError
            raise
          rescue StandardError => e
            raise Errors::VSphereError.new, e.message
          end
        end
      end
    end
  end
end
