# frozen_string_literal: true

require 'test_helper'

describe {{module}}::Greeting do
  describe '.call' do
    it 'greets the world when given no name' do
      assert_equal 'Hello, world!', {{module}}::Greeting.call
    end

    it 'greets the name it is given' do
      assert_equal 'Hello, Ada!', {{module}}::Greeting.call('Ada')
    end
  end
end
