# frozen_string_literal: true

require 'zeitwerk'

# Loads lib/ by file name: lib/{{require_path}}/greeting.rb is {{module}}::Greeting.
lib = __dir__ #: String
loader = Zeitwerk::Loader.new
loader.push_dir(lib)
loader.setup

module {{module}}
end
