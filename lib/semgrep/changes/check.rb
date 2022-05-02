# frozen_string_literal: true

module Semgrep
  module Changes
    class Check
      def initialize(path, analysis, patch)
        @path = path
        @analysis = analysis
        @patch = patch
      end

      def offenses
        analysis.select do |offense|
          line_numbers.include?(line(offense))
        end
      end

      attr_reader :path, :analysis, :patch

      private

      def line_numbers
        lines_from_diff & lines_from_semgrep
      end

      def lines_from_diff
        patch.changed_line_numbers
      end

      def lines_from_semgrep
        analysis
          .map(&method(:line))
          .uniq
      end

      def line(offense)
        offense.start.line
      end
    end
  end
end
