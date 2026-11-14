# frozen_string_literal: true

# A sample to replace with the gem's own code: it gives CI a module to lint,
# type-check and test.
module {{module}}::Greeting
  extend self

  # @rbs name: String?
  # @rbs return: String
  def call(name = nil)
    "Hello, #{name || 'world'}!"
  end
end
