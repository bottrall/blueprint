# frozen_string_literal: true

require 'test_helper'

describe RuboCop::Cop::Bottrall::MultipleAssertions do
  include CopHelper

  def cop_class = RuboCop::Cop::Bottrall::MultipleAssertions

  def check(source, max: 1)
    offense_lines(source, config: { 'Max' => max }, path: 'test/example_test.rb')
  end

  it 'flags an it block inside a top-level describe with two assertions' do
    assert_equal [2], check(<<~RUBY)
      describe 'Thing' do
        it 'does two things' do
          assert_equal 1, a
          assert_predicate b, :empty?
        end
      end
    RUBY
  end

  it 'allows an it block with one assertion' do
    assert_empty check("it 'does one thing' do\n  assert_equal 1, a\nend\n")
  end

  it 'flags a test block with two refutations' do
    assert_equal [1], check("test 'x' do\n  refute a\n  refute_nil b\nend\n")
  end

  it 'flags a specify block' do
    assert_equal [1], check("specify do\n  assert a\n  assert b\nend\n")
  end

  it 'flags a test method in a test class' do
    assert_equal [2], check(<<~RUBY)
      class ThingTest < Minitest::Test
        def test_two_things
          assert a
          assert b
        end
      end
    RUBY
  end

  it 'ignores a method that is not a test' do
    assert_empty check("def helper\n  assert a\n  assert b\nend\n")
  end

  it 'counts must and wont expectations' do
    assert_equal [1], check("it 'x' do\n  _(a).must_equal 1\n  _(b).wont_be_nil\nend\n")
  end

  it 'counts an expectation alongside an assertion' do
    assert_equal [1], check("it 'x' do\n  assert a\n  expect(b).must_be :empty?\nend\n")
  end

  it 'counts only the larger branch of an if' do
    assert_empty check("it 'x' do\n  if c\n    assert a\n  else\n    refute a\n  end\nend\n")
  end

  it 'flags a branch that makes two assertions' do
    assert_equal [1], check("it 'x' do\n  if c\n    assert a\n    assert b\n  end\nend\n")
  end

  it 'counts an assertion inside a block an assertion takes' do
    assert_equal [1], check("it 'x' do\n  assert_raises(E) do\n    assert a\n  end\nend\n")
  end

  it 'allows an assert_raises with no assertion inside it' do
    assert_empty check("it 'x' do\n  assert_raises(E) { run }\nend\n")
  end

  it 'counts flunk' do
    assert_equal [1], check("it 'x' do\n  assert a\n  flunk 'no'\nend\n")
  end

  it 'ignores assertion-like methods called on an object' do
    assert_empty check("it 'x' do\n  assert a\n  checker.assert_valid(b)\nend\n")
  end

  it 'ignores assertions in a before block' do
    assert_empty check("before do\n  assert a\n  assert b\nend\n")
  end

  it 'honours a higher Max' do
    assert_empty check("it 'x' do\n  assert a\n  assert b\nend\n", max: 2)
  end

  it 'reports the count and the limit' do
    message = offenses("it 'x' do\n  assert a\n  assert b\n  assert c\nend\n", config: { 'Max' => 1 }).map(&:message)

    assert_equal ['Test case has too many assertions [3/1].'], message
  end
end
