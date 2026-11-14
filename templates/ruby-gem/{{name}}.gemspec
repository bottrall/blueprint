# frozen_string_literal: true

require_relative 'lib/{{require_path}}/version'

Gem::Specification.new do |spec|
  spec.name = '{{name}}'
  spec.version = {{module}}::VERSION
  spec.authors = ['Jake Bottrall']
  spec.email = ['jakebottrall@gmail.com']

  spec.summary = '{{description}}'
  spec.homepage = 'https://github.com/bottrall/{{name}}'
  spec.license = 'MIT'
  # Every Ruby that isn't end-of-life.
  spec.required_ruby_version = '>= 3.3'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}/tree/main"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  # sig/_private ships too: RBS skips `_`-prefixed directories when the gem's
  # signatures are loaded as a library, so its stubs stay private.
  spec.files = Dir['lib/**/*.rb', 'sig/**/*.rbs', 'README.md', 'CHANGELOG.md', 'LICENSE']
  spec.require_paths = ['lib']

  spec.add_dependency 'zeitwerk', '~> 2.8'
end
