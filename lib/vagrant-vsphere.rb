# frozen_string_literal: true

require 'pathname'

require 'vSphere/plugin'

module VagrantPlugins
  module VSphere
    lib_path = Pathname.new(File.expand_path('vSphere', __dir__))
    autoload :Action, lib_path.join('action')
    autoload :Errors, lib_path.join('errors')

    # This returns the path to the source of this plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('..', __dir__))
    end
  end
end
