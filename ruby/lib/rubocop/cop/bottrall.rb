# frozen_string_literal: true

# The `Bottrall/` cop department.
module RuboCop::Cop::Bottrall
end

require_relative 'bottrall/no_inheritance'
require_relative 'bottrall/no_mocking'
require_relative 'bottrall/require_disable_reason'
