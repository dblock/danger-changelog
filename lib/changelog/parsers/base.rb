module Danger
  module Changelog
    module Parsers
      class Base
        def initialize(listeners = [], config: Danger::Changelog.config.with, added_lines: nil)
          raise ArgumentError, 'only_added requires added line numbers from a diff' if config.only_added && added_lines.nil?

          @listeners = listeners
          @config = config
          @added_lines = added_lines
          @line_numbers = {}.compare_by_identity
        end

        attr_reader :listeners, :config

        def add_listener(changelog)
          listeners << changelog
        end

        private

        def notify_of_bad_line(message, detail = nil)
          return if config.only_added && !@added_lines.include?(@line_numbers.fetch(message))

          listeners.each { |changelog| changelog.add_bad_line(message, detail) }
        end

        def track_line(line, number)
          @line_numbers[line] = number
          line
        end

        def notify_of_global_failure(message)
          listeners.each { |changelog| changelog.add_global_failure(message) }
        end
      end
    end
  end
end
