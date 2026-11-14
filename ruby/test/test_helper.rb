# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/spec'
require 'rubocop-bottrall'

# Runs one cop over a source string and returns its offenses.
module CopHelper
  def offenses(source, config: {}, path: 'lib/example.rb')
    rubocop_config = RuboCop::Config.new(cop_class.badge.to_s => config)
    processed = RuboCop::ProcessedSource.new(source, RUBY_VERSION.to_f, path)
    # Parsing a disable directive reads the registry and config, and without
    # them the commissioner swallows the error and reports no offenses.
    processed.registry = RuboCop::Cop::Registry.global
    processed.config = rubocop_config
    RuboCop::Cop::Commissioner.new([cop_class.new(rubocop_config)]).investigate(processed).offenses
  end

  def offense_lines(...)
    offenses(...).map(&:line)
  end
end
