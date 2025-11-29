module MyApplicationDavydenko
  class Configurator
    attr_reader :config

    DEFAULT_CONFIG = {
      run_website_parser:  0,
      run_save_to_csv:     0,
      run_save_to_json:    0,
      run_save_to_yaml:    0,
      run_save_to_sqlite:  0,
      run_save_to_mongodb: 0,
      run_save_media:      0
    }.freeze

    def initialize
      @config = DEFAULT_CONFIG.dup
    end

    def configure(overrides = {})
      overrides.each do |key, value|
        if @config.key?(key)
          @config[key] = value
        else
          puts "Warning: unknown config key: #{key}"
        end
      end

      @config
    end

    def self.available_methods
      DEFAULT_CONFIG.keys
    end
  end
end
