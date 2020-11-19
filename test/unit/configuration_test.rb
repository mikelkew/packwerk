# typed: ignore
# frozen_string_literal: true

require "test_helper"

module Packwerk
  class ConfigurationTest < Minitest::Test
    include ApplicationFixtureHelper

    setup do
      setup_application_fixture
    end

    teardown do
      teardown_application_fixture
    end

    test ".from_path raises ArgumentError if path does not exist" do
      File.expects(:exist?).with("foo").returns(false)
      error = assert_raises ArgumentError do
        Configuration.from_path("foo")
      end

      assert_equal("#{File.expand_path('foo')} does not exist", error.message)
    end

    test ".from_path uses packwerk config when it exists" do
      copy_template(:minimal)
      remove_app_entry("packwerk.yml")

      configuration_hash = {
        "include" => ["xyz/*.rb"],
        "exclude" => ["{exclude_dir,bin,tmp}/**/*"],
        "package_paths" => "**/*/",
        "load_paths" => ["app/models"],
        "custom_associations" => ["custom_association"],
        "inflections_file" => "custom_inflections.yml",
      }
      merge_into_yaml_file("packwerk.yml", configuration_hash)

      configuration = Configuration.from_path(app_dir)

      assert_equal ["xyz/*.rb"], configuration.include
      assert_equal ["{exclude_dir,bin,tmp}/**/*"], configuration.exclude
      assert_equal app_dir, configuration.root_path
      assert_equal ["app/models"], configuration.load_paths
      assert_equal "**/*/", configuration.package_paths
      assert_equal ["custom_association"], configuration.custom_associations
      assert_equal path_to("custom_inflections.yml"), configuration.inflections_file
    end

    test ".from_path falls back to some default config when no existing config exists" do
      copy_template(:minimal)
      remove_app_entry("packwerk.yml")

      configuration = Configuration.from_path

      assert_equal ["**/*.{rb,rake,erb}"], configuration.include
      assert_equal ["{bin,node_modules,script,tmp,vendor}/**/*"], configuration.exclude
      assert_equal app_dir, configuration.root_path
      assert_equal "**/", configuration.package_paths
      assert_empty configuration.custom_associations
      assert_equal path_to("config/inflections.yml"), configuration.inflections_file
    end
  end
end
