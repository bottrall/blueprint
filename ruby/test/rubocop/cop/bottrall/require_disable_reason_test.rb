# frozen_string_literal: true

require 'test_helper'

describe RuboCop::Cop::Bottrall::RequireDisableReason do
  include CopHelper

  def cop_class = RuboCop::Cop::Bottrall::RequireDisableReason

  it 'flags a disable without a reason' do
    assert_equal [1], offense_lines("run # rubocop:disable Style/Foo\n")
  end

  it 'flags a todo without a reason' do
    assert_equal [1], offense_lines("# rubocop:todo Style/Foo\n")
  end

  it 'flags a disable whose separator has no reason after it' do
    assert_equal [1], offense_lines("run # rubocop:disable Style/Foo --\n")
  end

  it 'allows a disable with a reason' do
    assert_empty offenses("run # rubocop:disable Style/Foo -- the API demands it\n")
  end

  it 'ignores an enable directive' do
    assert_empty offenses("# rubocop:enable Style/Foo\n")
  end

  it 'explains how to add a reason' do
    assert_equal ['Add a reason to the disable directive: end it with `-- <reason>`.'],
                 offenses("# rubocop:disable Style/Foo\n").map(&:message)
  end
end
