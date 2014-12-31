require 'rbvmomi'

module VagrantPlugins
  module VSphere
    module Action
      class CloseVSphere
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:vSphere_connection].close
          @app.call env
        rescue Errors::VSphereError => e
          raise
        rescue Exception => e
          raise Errors::VSphereError.new, e.message
        end
      end
    end
  end
end
