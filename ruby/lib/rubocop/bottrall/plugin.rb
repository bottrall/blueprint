# frozen_string_literal: true

require 'lint_roller'

# Registers the cops' defaults (config/default.yml) with RuboCop's plugin
# system, so `plugins: [rubocop-bottrall]` is all a project needs to load them.
class RuboCop::Bottrall::Plugin < LintRoller::Plugin
  def about
    LintRoller::About.new(
      name: 'rubocop-bottrall',
      version: RuboCop::Bottrall::VERSION,
      homepage: 'https://github.com/bottrall/blueprint/tree/main/ruby',
      description: 'The shared Ruby style and custom cops for bottrall projects.'
    )
  end

  def supported?(context)
    context.engine == :rubocop
  end

  def rules(_context)
    LintRoller::Rules.new(
      type: :path,
      config_format: :rubocop,
      value: Pathname.new(__dir__).join('../../../config/default.yml')
    )
  end
end
