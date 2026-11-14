# frozen_string_literal: true

# Every `rubocop:disable` / `rubocop:todo` has to say why: end it with `-- <reason>`.
class RuboCop::Cop::Bottrall::RequireDisableReason < RuboCop::Cop::Base
  MSG = 'Add a reason to the disable directive: end it with `-- <reason>`.'

  DISABLE_DIRECTIVE = /\A#\s*rubocop\s*:\s*(?:disable|todo)\b/
  REASON = /\s--\s*\S/

  def on_new_investigation
    processed_source.comments
                    .select { |comment| DISABLE_DIRECTIVE.match?(comment.text) && !REASON.match?(comment.text) }
                    .each { |comment| add_offense(comment) }
  end
end
