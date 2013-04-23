require 'rbvmomi'

module VagrantPlugins
  module VSphere
    module Action
      class CloseVSphere
        def initialize(app, env)
          @app = app
        end

        def call(env)
          begin
            env[:vSphere_connection].close
          rescue Exception => e
            #raise a properly namespaced error for Vagrant
            raise Errors::VSphereError, :message => e.message
          end
        end
      end
    end
  end
end