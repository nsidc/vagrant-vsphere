require 'rbvmomi'

module VagrantPlugins
  module VSphere
    module Action
      class ConnectVSphere
        def initialize(app, env)
          @app = app
        end

        def call(env)
          config = env[:machine].provider_config

          begin
            env[:vSphere_connection] = RbVmomi::VIM.connect host: config.host, user: config.user, password: config.password, insecure: config.insecure
            @app.call env
          rescue Exception => e
            puts "An error occurred while connecting to vSphere: " + e.to_s
            raise VagrantPlugins::VSphere::Errors::VSphereError, :message => e.message
          end
        end
      end
    end
  end
end
