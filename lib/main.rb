require_relative 'app_config_loader'
require_relative 'logger_manager'
require_relative 'items/item'  
require_relative 'items/cart'
require_relative 'configurator'
require_relative 'simple_website_parser'
require_relative 'database_connector'
require_relative 'engine'
require_relative 'archive_sender'

def main
  puts 'DEBUG PARSER MAIN START'

  AppConfigLoader.load_libs

  config = AppConfigLoader.config(
    default_config_path: File.expand_path('../config/yaml_config/default_config.yaml', __dir__),
    extra_configs_dir:   File.expand_path('../config/yaml_config', __dir__)
  )

  configurator = MyApplicationDavydenko::Configurator.new
  configurator.configure(
    run_website_parser:  1,
    run_save_to_csv:     1,
    run_save_to_json:    1,
    run_save_to_yaml:    1,
    run_save_media:      1,
    run_save_to_sqlite:  0,
    run_save_to_mongodb: 0
  )

  engine = MyApplicationDavydenko::Engine.new(config)
  engine.run(configurator.config)

  puts 'DEBUG PARSER MAIN FINISHED'
end

main if __FILE__ == $PROGRAM_NAME