# frozen_string_literal: true

require 'optparse'

module Semgrep
  module Changes
    class Options
      Options = Struct.new(:report, :quiet, :commit, :base_branch)

      def initialize
        @args = Options.new(nil, false, nil, 'main') # Defaults
      end

      def parse!
        OptionParser.new do |opts|
          opts.banner = 'Usage: semgrep-changes [options]'

          parse_report!(opts)
          parse_commit!(opts)
          parse_quiet!(opts)
          parse_help!(opts)
          parse_version!(opts)
          parse_base_branch!(opts)
        end.parse!

        args
      end

      private

      attr_reader :args

      def parse_report!(opts)
        opts.on(
          '-r',
          '--report [REPORT]',
          "Specify the semgrep report in json format"
        ) do |r|
          args.report = r
        end
      end

      def parse_commit!(opts)
        opts.on(
          '-c',
          '--commit [COMMIT_ID]',
          'Compare from some specific point on git history'
        ) do |c|
          args.commit = c
        end
      end

      def parse_quiet!(opts)
        opts.on('-q', '--quiet', 'Be quiet') do |v|
          args.quiet = v
        end
      end

      def parse_base_branch!(opts)
        opts.on('-b', '--base_branch [BRANCH]', 'Base branch to compare') do |v|
          args.base_branch = v
        end
      end

      def parse_help!(opts)
        opts.on('-h', '--help', 'Prints this help') do
          puts opts
          exit
        end
      end

      def parse_version!(opts)
        opts.on('--version', 'Display version') do
          puts Semgrep::Changes::VERSION
          exit 0
        end
      end
    end
  end
end
