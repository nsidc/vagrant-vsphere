# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

# Immediately sync all stdout so that tools like buildbot can
# immediately load in the output.
$stdout.sync = true
$stderr.sync = true

# Change to the directory of this file.
Dir.chdir(File.expand_path(__dir__))

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new

RuboCop::RakeTask.new

task default: %w[rubocop spec]
