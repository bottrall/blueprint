# frozen_string_literal: true

require 'test_helper'

describe RuboCop::Cop::Bottrall::NoInheritance do
  include CopHelper

  def cop_class = RuboCop::Cop::Bottrall::NoInheritance

  it 'allows a class without a parent' do
    assert_empty offenses("class Plain; end\n")
  end

  it 'flags a parent by default' do
    assert_equal [1], offense_lines("class Foo < Bar; end\n")
  end

  it 'flags the parent, not the class' do
    assert_equal 12, offenses("class Foo < Bar; end\n").first.column
  end

  it 'flags a parent that is not a constant' do
    assert_equal [1], offense_lines("class Point < Struct.new(:x); end\n")
  end

  it 'flags a class inheriting from an unlisted framework class' do
    assert_equal [1], offense_lines("class Read < Riffer::Tool; end\n")
  end

  describe 'with AllowedParents' do
    def allowed = { 'AllowedParents' => ['Riffer::Tool', '::ApplicationRecord'] }

    it 'allows a listed parent' do
      assert_empty offenses("class Read < Riffer::Tool; end\n", config: allowed)
    end

    it 'allows a top-level-qualified listed parent' do
      assert_empty offenses("class Read < ::Riffer::Tool; end\n", config: allowed)
    end

    it 'allows a parent listed with a top-level qualifier' do
      assert_empty offenses("class User < ApplicationRecord; end\n", config: allowed)
    end

    it 'flags a class nested under a listed parent' do
      assert_equal [1], offense_lines("class Fake < Riffer::Tool::Fake; end\n", config: allowed)
    end

    it 'flags an unlisted parent' do
      assert_equal [1], offense_lines("class Fake < Riffer::Rig::Hosts::Null; end\n", config: allowed)
    end
  end

  describe 'errors' do
    it 'allows Exception as a parent' do
      assert_empty offenses("class Signal < Exception; end\n")
    end

    it 'allows StandardError as a parent' do
      assert_empty offenses("class Busy < StandardError; end\n")
    end

    it 'allows a subclass of a core StandardError descendant' do
      assert_empty offenses("class Invalid < ArgumentError; end\n")
    end

    it 'allows a core StandardError descendant whose name does not end in Error' do
      assert_empty offenses("class Done < StopIteration; end\n")
    end

    it 'allows a top-level-qualified core error' do
      assert_empty offenses("class Done < ::StopIteration; end\n")
    end

    it 'allows a parent named like an error the cop cannot resolve' do
      assert_empty offenses("class Expired < Mcp::Auth::Error; end\n")
    end

    it 'allows a core error outside StandardError named like an error' do
      assert_empty offenses("class Pending < NotImplementedError; end\n")
    end

    it 'flags a core exception outside StandardError not named like an error' do
      assert_equal [1], offense_lines("class Halt < SystemExit; end\n")
    end

    it 'flags a loaded StandardError descendant defined in Ruby and not named like an error' do
      assert_equal [1], offense_lines("class Fault < Psych::Exception; end\n")
    end
  end
end
