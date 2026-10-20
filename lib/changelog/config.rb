module Danger
  module Changelog
    class Config
      DEFAULTS = {
        placeholder_line: "* Your contribution here.\n".freeze,
        filename: 'CHANGELOG.md'.freeze,
        format: :intridea,
        ignore_files: ['README.md'.freeze].freeze,
        strict_semver: true
      }.freeze
      ATTRIBUTES = DEFAULTS.keys.freeze
      DELEGATORS = (ATTRIBUTES + ATTRIBUTES.map { |name| :"#{name}=" }).freeze
      VALIDATORS = {
        placeholder_line: ->(value) { value.nil? || value.is_a?(String) },
        filename: ->(value) { value.is_a?(String) && !value.strip.empty? },
        format: ->(value) { (value.is_a?(String) || value.is_a?(Symbol)) && Parsers.valid?(value) },
        ignore_files: ->(value) { Array(value).all? { |item| item.is_a?(String) || item.is_a?(Regexp) } },
        strict_semver: ->(value) { [true, false].include?(value) }
      }.freeze

      attr_reader(*ATTRIBUTES)

      ATTRIBUTES.each do |name|
        define_method("#{name}=") do |value|
          raise ArgumentError, "Invalid #{name}: #{value}" unless VALIDATORS.fetch(name).call(value)

          instance_variable_set("@#{name}", snapshot(normalize(name, value)))
        end
      end

      def initialize(**options)
        unknown = options.keys - ATTRIBUTES
        raise ArgumentError, "Unknown changelog options: #{unknown.join(', ')}" unless unknown.empty?

        DEFAULTS.merge(options).each { |name, value| public_send("#{name}=", value) }
      end

      def with(**options)
        self.class.new(**to_h, **options).freeze
      end

      def to_h
        ATTRIBUTES.to_h { |name| [name, public_send(name)] }
      end

      def reset
        DEFAULTS.each { |name, value| public_send("#{name}=", value) }
      end

      def placeholder_line?
        !placeholder_line.nil?
      end

      def parser
        Parsers.lookup(format, config: with)
      end

      private

      def normalize(name, value)
        case name
        when :format then value.to_sym
        when :ignore_files then Array(value)
        when :placeholder_line
          return nil unless value

          value = "* #{value}" unless value.start_with?('* ')
          value.end_with?("\n") ? value : "#{value}\n"
        else value
        end
      end

      def snapshot(value)
        case value
        when Array then value.map { |item| snapshot(item) }.freeze
        when String, Regexp then value.dup.freeze
        else value
        end
      end
    end

    def self.configure
      warn '[DEPRECATION] `configure` is deprecated. Please directly configure the Danger plugin via `changelog.xyz=` instead.'
      block_given? ? yield(config) : config
    end

    def self.config
      @config ||= Config.new
    end
  end
end
