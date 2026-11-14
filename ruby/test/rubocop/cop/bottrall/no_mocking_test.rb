# frozen_string_literal: true

require 'test_helper'

describe RuboCop::Cop::Bottrall::NoMocking do
  include CopHelper

  def cop_class = RuboCop::Cop::Bottrall::NoMocking

  def owned = { 'OwnedNamespaces' => ['Riffer::Rig'] }

  def offense_lines_in_test(source, config: owned)
    offense_lines(source, config:, path: 'test/example_test.rb')
  end

  def offenses_in_test(source, config: owned)
    offenses(source, config:, path: 'test/example_test.rb')
  end

  it 'flags Minitest::Mock' do
    assert_equal [1], offense_lines_in_test("host = Minitest::Mock.new\n")
  end

  it 'flags a top-level-qualified Minitest::Mock' do
    assert_equal [1], offense_lines_in_test("host = ::Minitest::Mock.new\n")
  end

  it 'flags stub' do
    assert_equal [1], offense_lines_in_test("Time.stub(:now, 0) { run }\n")
  end

  it 'flags a singleton method defined on an owned constant' do
    assert_equal [1], offense_lines_in_test("Riffer::Rig::SDK.define_singleton_method(:bundler?) { false }\n")
  end

  it 'flags a singleton method defined on a top-level-qualified owned constant' do
    assert_equal [1], offense_lines_in_test("::Riffer::Rig::SDK.define_singleton_method(:bundler?) { false }\n")
  end

  it 'flags a singleton method defined on the owned namespace itself' do
    assert_equal [1], offense_lines_in_test("Riffer::Rig.define_singleton_method(:extension) { |*| nil }\n")
  end

  it 'flags a method defined on the singleton class of an owned constant' do
    assert_equal [1], offense_lines_in_test("Riffer::Rig::SDK.singleton_class.define_method(:bundler?) { false }\n")
  end

  it 'flags a method sent to the singleton class of an owned constant' do
    source = "Riffer::Rig::SDK.singleton_class.send(:define_method, :bundler?) { false }\n"

    assert_equal [1], offense_lines_in_test(source)
  end

  it 'flags a method defined on an owned class' do
    assert_equal [1], offense_lines_in_test("Riffer::Rig::Runtime.define_method(:close) { nil }\n")
  end

  it 'flags a method sent to an owned class' do
    assert_equal [1], offense_lines_in_test("Riffer::Rig::Runtime.send(:define_method, :close) { nil }\n")
  end

  it 'flags a method sent with __send__ to an owned class' do
    assert_equal [1], offense_lines_in_test("Riffer::Rig::Runtime.__send__(:define_method, :close) { nil }\n")
  end

  it 'allows a singleton method defined on a third-party constant' do
    assert_empty offenses_in_test("Gem.define_singleton_method(:find_files) { |_glob| [] }\n")
  end

  it 'allows a singleton method defined on a constant that only shares the namespace prefix' do
    assert_empty offenses_in_test("Riffer::Rigging.define_singleton_method(:bundler?) { false }\n")
  end

  it 'flags a singleton method defined on a local built from an owned constant' do
    source = "host = Riffer::Rig::Hosts::Null.new\nhost.define_singleton_method(:notify) { |*| nil }\n"

    assert_equal [2], offense_lines_in_test(source)
  end

  it 'flags a singleton method given without a block on a local built from an owned constant' do
    source = "host = Riffer::Rig::Hosts::Null.new\nhost.define_singleton_method(:notify, handler)\n"

    assert_equal [2], offense_lines_in_test(source)
  end

  it 'allows a singleton method defined on a local built from another constant' do
    assert_empty offenses_in_test("io = StringIO.new\nio.define_singleton_method(:tty?) { true }\n")
  end

  it 'allows a singleton method defined on a local a helper returned' do
    assert_empty offenses_in_test("host = build_host\nhost.define_singleton_method(:notify) { |*| nil }\n")
  end

  it 'allows a singleton method defined on a local an owned constant built only in another scope' do
    source = <<~RUBY
      it('builds') { host = Riffer::Rig::Hosts::Null.new }
      it('patches') do
        host = FakeHost.new
        host.define_singleton_method(:notify) { |*| nil }
      end
    RUBY

    assert_empty offenses_in_test(source)
  end

  it 'allows a singleton method defined on an instance variable' do
    assert_empty offenses_in_test("@host.define_singleton_method(:notify) { |*| nil }\n")
  end

  it 'allows an injected fake' do
    assert_empty offenses_in_test("runtime = Runtime.new(host: FakeHost.new)\n")
  end

  describe 'with several OwnedNamespaces' do
    def owned_twice = { 'OwnedNamespaces' => ['Riffer::Rig', '::Skyward'] }

    it 'flags a patch on the first namespace' do
      assert_equal [1], offense_lines_in_test("Riffer::Rig.define_singleton_method(:x) { 1 }\n", config: owned_twice)
    end

    it 'flags a patch on a namespace listed with a top-level qualifier' do
      assert_equal [1], offense_lines_in_test("Skyward::API.define_singleton_method(:x) { 1 }\n", config: owned_twice)
    end
  end

  describe 'without OwnedNamespaces' do
    def none = {}

    it 'flags stub' do
      assert_equal [1], offense_lines_in_test("Time.stub(:now, 0) { run }\n", config: none)
    end

    it 'flags Minitest::Mock' do
      assert_equal [1], offense_lines_in_test("host = Minitest::Mock.new\n", config: none)
    end

    it 'allows a singleton method defined on any constant' do
      assert_empty offenses_in_test("Riffer::Rig::SDK.define_singleton_method(:bundler?) { false }\n", config: none)
    end

    it 'allows a method defined on any class' do
      assert_empty offenses_in_test("Riffer::Rig::Runtime.define_method(:close) { nil }\n", config: none)
    end

    it 'allows a singleton method defined on a local built from any constant' do
      source = "host = Riffer::Rig::Hosts::Null.new\nhost.define_singleton_method(:notify) { |*| nil }\n"

      assert_empty offenses_in_test(source, config: none)
    end
  end
end
