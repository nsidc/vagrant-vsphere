require 'vSphere/util/machine_helpers'

module VagrantPlugins
  module VSphere
    module Action
      class IsRunning
        include Util::MachineHelpers
        
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:result] = env[:machine].state.id == :running
          @app.call env
        end
      end
    end
  end
end
