require 'rbvmomi'

module VagrantPlugins
  module VSphere
    module Action
      class ConnectVSphere
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          config = env[:machine].provider_config

          begin
            env[:vSphere_connection] = RbVmomi::VIM.connect host: config.host,
                                                            user: config.user, password: config.password,
                                                            insecure: config.insecure, proxyHost: config.proxy_host,
                                                            proxyPort: config.proxy_port
            @app.call env
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
