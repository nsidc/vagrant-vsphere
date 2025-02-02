require 'rbvmomi'

module VagrantPlugins
  module VSphere
    module Action
      class CloseVSphere
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:vSphere_connection].close if env && env[:vSphere_connection]
          @app.call env
        rescue Errors::VSphereError
          raise
        rescue StandardError => e
          raise Errors::VSphereError.new, e.message, e.backtrace
        end
      end
    end
  end
end
