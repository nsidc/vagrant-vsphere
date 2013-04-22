require 'rbvmomi'

module VagrantPlugins
  module VSphere
    class IsCreated
      def initialize(app, env)
        @app = app
      end

      def call(env)
        vim = env[:vSphere_connection]
        raise Errors::VSphereError, :message => 'Cannot check if a machine is created without a connection' if vim.nil?

        @app.call env
      end
    end
  end
end