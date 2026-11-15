# frozen_string_literal: true

# A test makes at most `Max` assertions (default 1), so a failure names exactly
# one broken behaviour. Minitest/MultipleAssertions only looks inside a class
# whose name ends in `Test`, so it never sees a spec written as a top-level
# `describe`; this cop checks every `it`, `test` and `specify` block wherever it
# is, plus `def test_*` methods. It counts `assert*`, `refute*` and `flunk`
# calls and `must_*` / `wont_*` expectations; in an `if` or `case` only the
# branch with the most assertions counts, as in Minitest/MultipleAssertions.
class RuboCop::Cop::Bottrall::MultipleAssertions < RuboCop::Cop::Base
  MSG = 'Test case has too many assertions [%<total>d/%<max>d].'

  TEST_BLOCKS = %i[it test specify].freeze
  ASSERTION = /\A(?:assert|refute)(?:_|\z)|\Aflunk\z/
  EXPECTATION = /\A(?:must|wont)_/

  def on_block(node)
    return unless test_block?(node)

    check(node)
  end
  alias on_numblock on_block
  alias on_itblock on_block

  def on_def(node)
    return unless node.method_name.to_s.start_with?('test_') && !node.arguments?

    check(node)
  end

  private

  def check(node)
    total = count(node.body)
    return if total <= max

    add_offense(node, message: format(MSG, total: total, max: max))
  end

  def max
    cop_config.fetch('Max', 1)
  end

  def test_block?(node)
    node.send_node.receiver.nil? && TEST_BLOCKS.include?(node.method_name)
  end

  def count(node)
    return 0 unless node.is_a?(RuboCop::AST::Node)

    case node.type
    when :if, :case, :case_match
      most(node.branches)
    when :rescue
      count(node.body) + most(node.branches)
    when :block, :numblock, :itblock
      test_block?(node) ? 0 : count(node.send_node) + count(node.body)
    else
      own(node) + node.each_child_node.sum { |child| count(child) }
    end
  end

  def most(branches)
    branches.map { |branch| count(branch) }.max || 0
  end

  def own(node)
    return 0 unless node.send_type?

    name = node.method_name.to_s
    assertion = node.receiver.nil? && ASSERTION.match?(name)
    assertion || EXPECTATION.match?(name) ? 1 : 0
  end
end
