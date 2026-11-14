# frozen_string_literal: true

# Flags a class with a superclass, unless the superclass is
#
# - listed in `AllowedParents` (framework-mandated parents),
# - named `...Error`, or
# - a core class that is `Exception` or descends from `StandardError`.
class RuboCop::Cop::Bottrall::NoInheritance < RuboCop::Cop::Base
  MSG = "Compose, don't inherit: pass collaborators in, share code through a mixin, and describe " \
        'contracts as RBS interfaces. Only errors and the framework parents in AllowedParents may be ' \
        'superclasses; for a one-off framework parent, add a scoped disable with a reason.'

  def on_class(node)
    parent = node.parent_class
    return unless parent
    return if parent.const_type? && allowed?(parent.const_name.delete_prefix('::'))

    add_offense(parent)
  end

  private

  def allowed?(name)
    allowed_parents.include?(name) || name.end_with?('Error') || core_error?(name)
  end

  def allowed_parents
    Array(cop_config['AllowedParents']).map { |parent| parent.delete_prefix('::') }
  end

  # Only core classes, defined in C, resolve the same in every process: a
  # gem's or the project's own error classes aren't loaded when the cop runs.
  def core_error?(name)
    return false unless Object.const_defined?(name) && Object.const_source_location(name) == []

    parent = Object.const_get(name)
    parent.is_a?(Class) && (parent.equal?(Exception) || parent <= StandardError)
  end
end
