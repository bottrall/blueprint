# frozen_string_literal: true

require_relative 'lib/rubocop/bottrall/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-bottrall'
  spec.version = RuboCop::Bottrall::VERSION
  spec.authors = ['Jake Bottrall']
  spec.email = ['jakebottrall@gmail.com']

  spec.summary = 'The shared RuboCop style and custom cops for bottrall projects.'
  spec.description = 'A RuboCop plugin bundling a shared style (config/base.yml), an rbs-inline layer ' \
                     '(config/rbs-inline.yml), and the Bottrall/NoInheritance, Bottrall/NoMocking and ' \
                     'Bottrall/RequireDisableReason cops.'
  spec.homepage = 'https://github.com/bottrall/blueprint/tree/main/ruby#readme'
  spec.license = 'MIT'
  # Every Ruby that isn't end-of-life.
  spec.required_ruby_version = '>= 3.3'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/bottrall/blueprint/tree/main/ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/bottrall/blueprint/blob/main/ruby/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/bottrall/blueprint/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['default_lint_roller_plugin'] = 'RuboCop::Bottrall::Plugin'

  spec.files = Dir['lib/**/*.rb', 'config/*.yml', 'README.md', 'CHANGELOG.md', 'LICENSE']
  spec.require_paths = ['lib']

  spec.add_dependency 'lint_roller', '~> 1.1'
  # 1.72 is the first RuboCop with the lint_roller plugin system.
  spec.add_dependency 'rubocop', '>= 1.72', '< 2'
  # The first releases that register as lint_roller plugins.
  spec.add_dependency 'rubocop-minitest', '~> 0.37'
  spec.add_dependency 'rubocop-performance', '~> 1.24'
  spec.add_dependency 'rubocop-rake', '~> 0.7'
end
