require 'yaml'
require 'erb'
require 'json'
require 'fileutils'

class AppConfigLoader
  class << self
    attr_reader :config_data

    def config(default_config_path:, extra_configs_dir:)
      default_cfg = load_yaml(default_config_path)
      extra_cfg   = load_all_yaml(extra_configs_dir)
      @config_data = deep_merge(default_cfg, extra_cfg)
    end

    def pretty_print_config_data
      puts JSON.pretty_generate(@config_data || {})
    end

    def load_libs
      require 'date'
      load_local_libs
    end

    private

    def load_yaml(path)
      return {} unless File.exist?(path)
      YAML.safe_load(ERB.new(File.read(path)).result, aliases: true) || {}
    end

    def load_all_yaml(dir)
      result = {}
      Dir.glob(File.join(dir, '*.y{a,}ml')).each do |file|
        next if File.basename(file) == 'default_config.yaml'
        data = YAML.safe_load(File.read(file), aliases: true) || {}
        result = deep_merge(result, data)
      end
      result
    end

    def deep_merge(a, b)
      a.merge(b) { |_, v1, v2| v1.is_a?(Hash) && v2.is_a?(Hash) ? deep_merge(v1, v2) : v2 }
    end

    def load_local_libs
      @loaded ||= []
      libs = File.expand_path('../libs', __dir__)
      return unless Dir.exist?(libs)

      Dir.glob(File.join(libs, '*.rb')).each do |file|
        next if @loaded.include?(file)
        require_relative File.join('..', 'libs', File.basename(file))
        @loaded << file
      end
    end
  end
end

