module VagrantPlugins
  module VSphere
    module Action
      class SnapshotSave
        def initialize(app, _env)
          @app = app
        end

        def call(env)
          snapshot_name = env[:snapshot_name]

          env[:ui].info(I18n.t("vagrant.actions.vm.snapshot.saving", name: snapshot_name))
          
          env[:machine].provider.driver.create_snapshot(snapshot_name) do |progress|
            env[:ui].clear_line
            env[:ui].report_progress(progress, 100, false)
          end

          env[:ui].clear_line
          env[:ui].success(I18n.t("vagrant.actions.vm.snapshot.saved", name: snapshot_name))
          
          @app.call env
        end
      end
    end
  end
end
