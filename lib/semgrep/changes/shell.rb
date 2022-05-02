# frozen_string_literal: true

module Semgrep
  module Changes
    class Shell
      def self.run(command)
        `#{command}`.strip
      end
    end
  end
end
