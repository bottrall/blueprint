# frozen_string_literal: true

require 'test_helper'
require 'yaml'

describe RuboCop::Bottrall::Plugin do
  def plugin = RuboCop::Bottrall::Plugin.new({})

  def context(engine) = LintRoller::Context.new(engine:)

  def defaults = YAML.safe_load_file(plugin.rules(context(:rubocop)).value)

  it 'supports RuboCop' do
    assert plugin.supported?(context(:rubocop))
  end

  it 'does not support other engines' do
    refute plugin.supported?(context(:standard))
  end

  it 'names itself after the gem' do
    assert_equal 'rubocop-bottrall', plugin.about.name
  end

  it 'reports the gem version' do
    assert_equal RuboCop::Bottrall::VERSION, plugin.about.version
  end

  it 'gives every cop in the department its defaults' do
    cops = RuboCop::Cop::Registry.global.with_department(:Bottrall).cops.map(&:cop_name)

    assert_equal cops.sort, defaults.keys.sort
  end

  it 'enables every cop' do
    assert(defaults.values.all? { |cop| cop['Enabled'] })
  end

  it 'allows no parents by default' do
    assert_empty defaults.dig('Bottrall/NoInheritance', 'AllowedParents')
  end

  it 'owns no namespaces by default' do
    assert_empty defaults.dig('Bottrall/NoMocking', 'OwnedNamespaces')
  end
end
