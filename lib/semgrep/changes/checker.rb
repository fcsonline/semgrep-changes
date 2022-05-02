# frozen_string_literal: true

require 'git_diff_parser'
require 'json'

require 'semgrep/changes/check'
require 'semgrep/changes/shell'

module Semgrep
  module Changes
    class UnknownForkPointError < StandardError; end

    class Checker
      def initialize(report:, quiet:, commit:, base_branch:)
        @report = report
        @quiet = quiet
        @commit = commit
        @base_branch = base_branch
      end

      def run
        raise UnknownForkPointError if fork_point.empty?

        print_offenses! unless quiet

        total_offenses
      end

      private

      attr_reader :report, :format, :quiet, :commit

      def fork_point
        @fork_point ||= Shell.run(command)
      end

      def command
        return "git merge-base HEAD origin/#{@base_branch}" unless commit

        "git log -n 1 --pretty=format:\"%h\" #{commit}"
      end

      def diff
        Shell.run("git diff #{fork_point}")
      end

      def patches
        @patches ||= GitDiffParser.parse(diff)
      end

      def changed_files
        patches.map(&:file)
      end

      def semgrep_json
        @semgrep_json ||= JSON.parse(File.read(report), object_class: OpenStruct)
      end

      def checks
        @checks ||= changed_files.map do |file|
          analysis = semgrep_json.results.select { |item| item.path == file }
          patch = patches.find { |item| item.file == file }

          next unless analysis

          Check.new(file, analysis, patch)
        end.compact
      end

      def total_offenses
        checks.map { |check| check.offenses.size }.inject(0, :+)
      end

      def print_offenses!
        msg "Findings:"
        msg ""

        checks.each do |check|
          print_offenses_for_check(check)
        end

        msg "Some files were skipped."
        msg "  Scan was limited to files tracked by git."
        msg ""
        msg "Ran 1 rule on 11 files: #{total_offenses} finding."
      end

      def print_offenses_for_check(check)
        return unless check.offenses.length > 0

        msg "  #{check.path}"
        check.offenses.map do |offense|
          msg "    #{offense.check_id}"
          msg "      #{offense.extra.message}"
          msg ""
          msg "       #{offense.start.line}┆ #{offense.extra.lines&.strip}"
          msg ""
        end
      end

      def msg(message)
        return if ENV['RACK_ENV'] == 'test'

        puts message
      end
    end
  end
end
