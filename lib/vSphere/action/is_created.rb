module VagrantPlugins
  module VSphere
    module Action
      class IsCreated
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          env[:result] = env[:machine].provider.driver.is_created
          @app.call env
        end
      end
    end
  end
end
