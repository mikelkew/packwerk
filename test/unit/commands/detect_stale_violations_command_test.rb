# frozen_string_literal: true
require "test_helper"
require "rails_test_helper"
require "packwerk/commands/detect_stale_violations_command"
require "byebug"

module Packwerk
  class DetectStaleViolationsCommandTest < Minitest::Test
    test "#execute_command with the subcommand detect-stale-violations returns status code 1 if stale violations" do
      stale_violations_message = "There were stale violations found, please run `packwerk update`"
      offense = stub
      detect_stale_deprecated_references = stub
      detect_stale_deprecated_references.stubs(:stale_violations?).returns(true)

      progress_formatter = stub
      progress_formatter.stubs(:started)

      progress_formatter.stubs(:finished)

      run_context = stub
      run_context.stubs(:process_file).returns(offense)

      ::Packwerk::FilesForProcessing.stubs(fetch: ["path/of/exile.rb"])
      ::Packwerk::RunContext.stubs(from_configuration: run_context)

      detect_stale_violations_command = ::Packwerk::DetectStaleViolationsCommand.new(
        files: ["path/of/exile.rb"],
        configuration: Configuration.from_path,
        run_context: run_context,
        reference_lister: detect_stale_deprecated_references,
        progress_formatter: progress_formatter
      )

      detect_stale_violations_command.stubs(:mark_progress)

      no_stale_violations = detect_stale_violations_command.run

      assert_equal no_stale_violations.message, stale_violations_message
      refute no_stale_violations.status
    end
  end
end
