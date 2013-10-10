module VagrantPlugins
  module VSphere
    module Action
      class IsRunning
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
