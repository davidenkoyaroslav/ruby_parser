require_relative 'app_config_loader'
require_relative 'logger_manager'
require_relative 'items/item'  
require_relative 'items/cart'
require_relative 'configurator'
require_relative 'simple_website_parser'
require_relative 'database_connector'
require_relative 'engine'
require_relative 'archive_sender'

=begin
def main
  # Автоматичне підключення бібліотек
  AppConfigLoader.load_libs

  # Завантаження конфігурацій
  config = AppConfigLoader.config(
    default_config_path: File.expand_path('../config/yaml_config/default_config.yaml', __dir__),
    extra_configs_dir:   File.expand_path('../config/yaml_config', __dir__)
  )

  # Перевірка завантаження конфігів (вивід JSON)
  AppConfigLoader.pretty_print_config_data

  # Логування (на основі logging.yaml)
  MyApplicationDavydenko::LoggerManager.setup(config)
  MyApplicationDavydenko::LoggerManager.log_processed_file('config/yaml_config/web_parser.yaml')
  MyApplicationDavydenko::LoggerManager.log_error('Test error message')
  cart = MyApplicationDavydenko::Cart.new
cart.generate_test_items(3)

cart.add_item(MyApplicationDavydenko::Item.new(name: "Aspirin", price: 100))

puts "All items:"
cart.show_all_items

cart.save_to_file("output/items.txt")
cart.save_to_json("output/items.json")
cart.save_to_csv("output/items.csv")
cart.save_to_yml("output/yml_items")

  configurator = MyApplicationDavydenko::Configurator.new
  configurator.configure(
    run_website_parser:  1,
    run_save_to_csv:     1,
    run_save_to_json:    1
  )

  if configurator.config[:run_website_parser] == 1
    parser = MyApplicationDavydenko::SimpleWebsiteParser.new(config)
    parser.start_parse
    cart_from_site = parser.item_collection

    cart_from_site.save_to_csv("output/parsed_items.csv")  if configurator.config[:run_save_to_csv]  == 1
    cart_from_site.save_to_json("output/parsed_items.json") if configurator.config[:run_save_to_json] == 1
  end
  if configurator.config[:run_save_to_sqlite] == 1 || configurator.config[:run_save_to_mongodb] == 1
    db_connector = MyApplicationDavydenko::DatabaseConnector.new(config)
    db = db_connector.connect_to_database
    puts "\nDatabase connected: #{!db.nil?}"
    db_connector.close_connection
  end


  
end

main if __FILE__ == $PROGRAM_NAME
=end


def main
  puts "=== APPLICATION START ==="

  # 1. Автоматичне підключення бібліотек
  AppConfigLoader.load_libs

  # 2. Завантаження конфігів
  config = AppConfigLoader.config(
    default_config_path: File.expand_path('../config/yaml_config/default_config.yaml', __dir__),
    extra_configs_dir:   File.expand_path('../config/yaml_config', __dir__)
  )

  # 3. Налаштування конфігуратора (включаємо потрібні дії)
  configurator = MyApplicationDavydenko::Configurator.new
  configurator.configure(
    run_website_parser:  1,
    run_save_to_csv:     1,
    run_save_to_json:    1,
    run_save_to_yaml:    1,
    run_save_to_sqlite:  0, # 1 — увімкнути SQLite
    run_save_to_mongodb: 0  # 1 — увімкнути MongoDB
  )

  # 4. Запуск головного рушія
  engine = MyApplicationDavydenko::Engine.new(config)
  engine.run(configurator.config)

  puts "=== APPLICATION FINISHED ==="
end

main if __FILE__ == $PROGRAM_NAME
