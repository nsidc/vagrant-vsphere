module VagrantPlugins
  module VSphere
    module Action
      class IsSuspended
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:result] = env[:machine].state.id == :suspended
          @app.call env
        end
      end
    end
  end
end
