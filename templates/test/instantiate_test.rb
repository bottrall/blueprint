# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'minitest/autorun'
require 'minitest/spec'
require 'open3'
require 'rbconfig'
require 'tmpdir'

TEMPLATES = File.expand_path('..', __dir__)

# A throwaway blueprint checkout: templates/instantiate beside a small shared
# template, one stack template and agents/, so each test sees exactly the
# inputs it names.
module Fixture
  extend self

  SHARED = {
    'templates/shared/template.json' => JSON.generate(
      'placeholders' => { 'name' => 'n', 'year' => 'y' },
      'executable' => %w[bin/test bin/dev],
      'exclude' => %w[README.md template.json test]
    ),
    'templates/shared/README.md' => 'About the shared template',
    'templates/shared/test/run' => 'shared tests',
    'templates/shared/bin/test' => "#!/usr/bin/env bash\n",
    'templates/shared/bin/dev' => "#!/usr/bin/env bash\n",
    'templates/shared/LICENSE' => "Copyright (c) {{year}}\n",
    'templates/shared/shared.txt' => "from shared\n",
    'templates/shared/both.txt' => "shared's\n",
    'templates/shared/CONTRIBUTING.md' => "| `bin/test [paths]` | tests |\n| `bin/dev` | runs |\n"
  }.freeze

  STACK = {
    'templates/stack/template.json' => JSON.generate(
      'placeholders' => { 'name' => 'n', 'module' => 'm', 'require_path' => 'r' },
      'executable' => ['exe/{{name}}'],
      'exclude' => ['template.json'],
      'remove' => ['bin/dev']
    ),
    'templates/stack/both.txt' => "{{name}}'s\n",
    'templates/stack/lib/{{require_path}}.rb' => "module {{module}}\nend\n",
    'templates/stack/exe/{{name}}' => "#!/usr/bin/env ruby\n",
    'templates/stack/AGENTS.md' => "# {{name}}\n\n{{> agents/commands.md}}\n\nEnd\n",
    'templates/stack/ci.yml' => "run: ${{ matrix.run }}\n",
    'agents/commands.md' => "## Commands\n\n| `bin/test` | tests |\n| `bin/dev` | runs |\n"
  }.freeze

  VALUES = %w[name=my-gem module=My::Gem require_path=my/gem year=2026].freeze

  def create(root, files = {})
    FileUtils.mkdir_p(File.join(root, 'templates'))
    FileUtils.cp(File.join(TEMPLATES, 'instantiate'), File.join(root, 'templates', 'instantiate'))
    SHARED.merge(STACK).merge(files).compact.each do |path, content|
      FileUtils.mkdir_p(File.dirname(File.join(root, path)))
      File.write(File.join(root, path), content)
    end
    root
  end

  # @return [stdout and stderr, exit status]
  def instantiate(root, *)
    output, status = Open3.capture2e(RbConfig.ruby, File.join(root, 'templates', 'instantiate'), *)
    [output, status.exitstatus]
  end
end

describe 'templates/instantiate' do
  let(:root) { Dir.mktmpdir('instantiate-test') }
  let(:target) { File.join(root, 'out') }

  after { FileUtils.remove_entry(root) }

  def run_stack(*args, files: {})
    Fixture.create(root, files)
    Fixture.instantiate(root, 'stack', target, *args)
  end

  def project_files
    Dir.glob('**/*', File::FNM_DOTMATCH, base: target).reject { |path| File.directory?(File.join(target, path)) }.sort
  end

  def read(path)
    File.read(File.join(target, path))
  end

  describe 'arguments' do
    it 'prints its usage and the templates there are with no arguments' do
      Fixture.create(root)

      assert_match(/Templates: stack$/, Fixture.instantiate(root).first)
    end

    it 'refuses a template that does not exist' do
      Fixture.create(root)

      assert_equal 2, Fixture.instantiate(root, 'nope', target, *Fixture::VALUES).last
    end

    it 'refuses the shared template on its own' do
      Fixture.create(root)

      assert_equal 2, Fixture.instantiate(root, 'shared', target, *Fixture::VALUES).last
    end

    it 'refuses a target directory that is not empty' do
      FileUtils.mkdir_p(target)
      File.write(File.join(target, 'keep.txt'), 'mine')

      assert_equal 2, run_stack(*Fixture::VALUES).last
    end

    it 'leaves a non-empty target directory as it was' do
      FileUtils.mkdir_p(target)
      File.write(File.join(target, 'keep.txt'), 'mine')
      run_stack(*Fixture::VALUES)

      assert_equal ['keep.txt'], project_files
    end

    it 'fills an existing empty target directory' do
      FileUtils.mkdir_p(target)

      assert_equal 0, run_stack(*Fixture::VALUES).last
    end

    it 'names a placeholder that was not given' do
      assert_match(/missing module=/, run_stack(*Fixture::VALUES.reject { |pair| pair.start_with?('module=') }).first)
    end

    it 'refuses a key that is not one of the placeholders' do
      assert_match(/colour isn't a placeholder/, run_stack(*Fixture::VALUES, 'colour=red').first)
    end

    it 'refuses an argument that is not key=value' do
      assert_match(/oops isn't key=value/, run_stack(*Fixture::VALUES, 'oops').first)
    end

    it 'defaults year to this year' do
      run_stack(*Fixture::VALUES.reject { |pair| pair.start_with?('year=') })

      assert_equal "Copyright (c) #{Time.now.year}\n", read('LICENSE')
    end

    it 'keeps an = inside a value' do
      run_stack(*Fixture::VALUES.reject { |pair| pair.start_with?('name=') }, 'name=a=b')

      assert_equal "a=b's\n", read('both.txt')
    end
  end

  describe 'layering' do
    before { run_stack(*Fixture::VALUES) }

    it 'copies the shared template, then the stack template, leaving out excluded and removed paths' do
      expected = %w[AGENTS.md CONTRIBUTING.md LICENSE bin/test both.txt ci.yml exe/my-gem lib/my/gem.rb shared.txt]

      assert_equal expected, project_files
    end

    it "lets the stack template's file win over the shared one" do
      assert_equal "my-gem's\n", read('both.txt')
    end

    it 'drops the bin/ table rows of removed scripts from CONTRIBUTING.md' do
      assert_equal "| `bin/test [paths]` | tests |\n", read('CONTRIBUTING.md')
    end

    it 'makes the paths both layers list as executable executable' do
      assert(%w[bin/test exe/my-gem].all? { |path| File.executable?(File.join(target, path)) })
    end

    it 'leaves the other files unexecutable' do
      refute File.executable?(File.join(target, 'shared.txt'))
    end
  end

  describe 'rendering' do
    before { run_stack(*Fixture::VALUES) }

    it 'substitutes placeholders in file contents' do
      assert_equal "module My::Gem\nend\n", read('lib/my/gem.rb')
    end

    it 'expands includes after substitution and drops the removed scripts from the bin/ table' do
      assert_equal "# my-gem\n\n## Commands\n\n| `bin/test` | tests |\n\nEnd\n", read('AGENTS.md')
    end

    it 'leaves GitHub Actions expressions alone' do
      assert_equal "run: ${{ matrix.run }}\n", read('ci.yml')
    end
  end

  describe 'leftovers' do
    it 'keeps double braces that are not placeholders, such as a JSX object literal' do
      _, status = run_stack(*Fixture::VALUES, files: { 'templates/stack/app.tsx' => "<A b={{ c: 1 }} />\n" })

      assert_equal 0, status
    end

    it 'refuses a file holding a placeholder the template does not declare' do
      output, = run_stack(*Fixture::VALUES, files: { 'templates/stack/odd.txt' => '{{colour}}' })

      assert_match(/odd.txt still holds \{\{colour\}\}/, output)
    end

    it 'writes nothing when a placeholder would be left' do
      run_stack(*Fixture::VALUES, files: { 'templates/stack/odd.txt' => '{{colour}}' })

      refute Dir.exist?(target)
    end

    it 'refuses an include of a file agents/ does not have' do
      output, = run_stack(*Fixture::VALUES, files: { 'templates/stack/odd.md' => "{{> agents/nope.md}}\n" })

      assert_match(%r{odd.md still holds \{\{> agents/nope.md\}\}}, output)
    end

    it 'refuses an include that is not on a line of its own' do
      output, = run_stack(*Fixture::VALUES, files: { 'templates/stack/odd.md' => "See {{> agents/commands.md}}\n" })

      assert_match(/odd.md still holds/, output)
    end

    it 'refuses a path holding a placeholder the template does not declare' do
      output, = run_stack(*Fixture::VALUES, files: { 'templates/stack/{{colour}}.txt' => '' })

      assert_match(/path \{\{colour\}\}.txt still holds/, output)
    end
  end

  describe 'template.json' do
    it 'refuses a removal no layer has' do
      stack = JSON.parse(Fixture::STACK.fetch('templates/stack/template.json')).merge('remove' => ['bin/gone'])
      output, = run_stack(*Fixture::VALUES, files: { 'templates/stack/template.json' => JSON.generate(stack) })

      assert_match(%r{removes bin/gone, which no layer has}, output)
    end

    it 'refuses an executable no layer has' do
      stack = JSON.parse(Fixture::STACK.fetch('templates/stack/template.json')).merge('executable' => ['exe/gone'])
      output, = run_stack(*Fixture::VALUES, files: { 'templates/stack/template.json' => JSON.generate(stack) })

      assert_match(%r{exe/gone is listed as executable}, output)
    end
  end

  # The real templates, each instantiated with every placeholder it declares:
  # each must leave nothing unsubstituted.
  describe 'the templates in this repo' do
    templates = Dir.glob('*/template.json', base: TEMPLATES).map { |path| File.dirname(path) } - ['shared']

    templates.each do |template|
      it "instantiates #{template}" do
        placeholders = ['shared', template].flat_map do |name|
          JSON.parse(File.read(File.join(TEMPLATES, name, 'template.json'))).fetch('placeholders', {}).keys
        end
        values = placeholders.uniq.map { |key| "#{key}=sample" }
        _, status = Open3.capture2e(RbConfig.ruby, File.join(TEMPLATES, 'instantiate'), template, target, *values)

        assert_equal 0, status.exitstatus
      end
    end
  end
end
