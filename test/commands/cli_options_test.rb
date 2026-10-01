# frozen_string_literal: true

require_relative '../test_helper'

# Thor keys its options hash by the name the option is *declared* with, so
# `option :'publish-file'` is readable only as `options['publish-file']`--while
# every command here reads `options['publish_file']`. Declaring the underscored
# name keeps both `--publish-file` and `--publish_file` working on the command
# line and lines the key up with the reader, so these tests pin the declarations
# rather than trusting them to stay in sync by eye.
class CliOptionsTest < Minitest::Test
  # Each command, and the file-path option its body reads out of `options`.
  FILE_OPTIONS = {
    BookCli => { 'render' => :publish_file, 'console' => :publish_file,
                 'publish' => :publish_file, 'lint' => :publish_file },
    VideoCli => { 'render' => :release_file, 'console' => :release_file,
                  'upload' => :release_file, 'lint' => :release_file,
                  'slides' => :release_file },
    ContentModuleCli => { 'render' => :module_file, 'lint' => :module_file,
                          'circulate' => :module_file, 'slides' => :module_file }
  }.freeze

  # `method_options` (plural) takes name => type pairs, so passing it `aliases:`
  # and friends silently declares options called `aliases`, `default` and
  # `desc`. `method_option` (singular) is the one that takes them as settings.
  LINT_OPTIONS = {
    BookCli => %i[publish_file without-edition silent],
    VideoCli => %i[release_file without-version silent],
    ContentModuleCli => %i[module_file without-version silent]
  }.freeze

  def parse(cli, command, argv)
    Thor::Options.new(cli.commands.fetch(command).options).parse(argv)
  end

  def test_every_command_declares_the_file_option_its_body_reads
    FILE_OPTIONS.each do |cli, commands|
      commands.each do |command, expected|
        assert_includes cli.commands.fetch(command).options.keys, expected,
                        "#{cli}##{command} should declare #{expected}"
      end
    end
  end

  def test_the_dashed_command_line_form_still_reaches_the_underscored_key
    FILE_OPTIONS.each do |cli, commands|
      commands.each do |command, expected|
        switch = "--#{expected.to_s.tr('_', '-')}"
        parsed = parse(cli, command, [switch, '/data/src/thing.yaml'])

        assert_equal '/data/src/thing.yaml', parsed[expected.to_s],
                     "#{cli}##{command} should accept #{switch}"
      end
    end
  end

  def test_the_underscored_command_line_form_works_too
    parsed = parse(BookCli, 'lint', ['--publish_file', '/data/src/publish.yaml'])

    assert_equal '/data/src/publish.yaml', parsed['publish_file']
  end

  def test_lint_commands_declare_no_stray_options
    LINT_OPTIONS.each do |cli, expected|
      assert_equal expected.sort, cli.commands.fetch('lint').options.keys.sort,
                   "#{cli}#lint has unexpected options"
    end
  end

  def test_lint_commands_keep_their_short_aliases
    LINT_OPTIONS.each_key do |cli|
      options = cli.commands.fetch('lint').options
      branch_check = options.keys.find { _1.to_s.start_with?('without-') }

      assert_equal ['-e'], options.fetch(branch_check).aliases
      assert_equal ['-s'], options.fetch(:silent).aliases
    end
  end

  def test_lint_branch_check_and_silent_default_to_false
    LINT_OPTIONS.each_key do |cli|
      parsed = parse(cli, 'lint', [])
      branch_check = cli.commands.fetch('lint').options.keys.find { _1.to_s.start_with?('without-') }

      assert_equal false, parsed[branch_check.to_s], "#{cli}#lint #{branch_check} should default to false"
      assert_equal false, parsed['silent'], "#{cli}#lint silent should default to false"
    end
  end
end
