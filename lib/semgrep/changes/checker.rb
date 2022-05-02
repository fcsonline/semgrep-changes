# frozen_string_literal: true

require 'git_diff_parser'
require 'rubocop'
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

        checks.map(&:offenses).flatten
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
          analysis = semgrep_json.files.find { |item| item.path == file }
          patch = patches.find { |item| item.file == file }

          next unless analysis

          Check.new(analysis, patch)
        end.compact
      end

      def offended_lines
        checks.map(&:offended_lines).flatten.compact
      end

      def total_offenses
        checks.map { |check| check.offended_lines.size }.inject(0, :+)
      end

      def print_offenses!
        checks.each do |check|
          print_offenses_for_check(check)
        end
      end

      def print_offenses_for_check(check)
        offenses = check.offenses.map do |offense|
          RuboCop::Cop::Offense.new(
            offense.severity,
            offense.location,
            offense.message,
            offense.cop_name
          )
        end
      end
    end
  end
end
