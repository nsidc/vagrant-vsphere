require 'rbvmomi'

module VagrantPlugins
  module VSphere
    class ConnectVSphere
      def initialize(app, env)
        @app = app
      end

      def call(env)
        config = env[:machine].provider_config

        begin
          env[:vSphere_connection] = RbVmomi::VIM.connect host: config.host, user: config.user, password: config.password
          @app.call env
        rescue Exception => e
          #raise a properly namespaced error for Vagrant
          raise Errors::VSphereError, :message => e.message
        end
      end
    end
  end
end