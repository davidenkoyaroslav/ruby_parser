require_relative 'logger_manager'
require_relative 'database_connector'
require_relative 'simple_website_parser'

module MyApplicationDavydenko
  class Engine
    def initialize(config)
      @config = config
    end

    def run(params)
      MyApplicationDavydenko::LoggerManager.setup(@config)

      db = MyApplicationDavydenko::DatabaseConnector.new(@config)
      db.connect_to_database

      params.each do |method_name, flag|
        next unless flag == 1
        send(method_name) if respond_to?(method_name, true)
      end

      db.close_connection
    end

    private

    def run_website_parser
      parser = MyApplicationDavydenko::SimpleWebsiteParser.new(@config)
      parser.start_parse
      @items = parser.item_collection
    end

    def run_save_to_csv
      @items&.save_to_csv('output/engine_items.csv')
    end

    def run_save_to_json
      @items&.save_to_json('output/engine_items.json')
    end

    def run_save_to_yaml
      @items&.save_to_yml('output/engine_items_yml')
    end

    def run_save_to_sqlite
      puts 'run_save_to_sqlite called (stub)'
    end

    def run_save_to_mongodb
      puts 'run_save_to_mongodb called (stub)'
    end
  end
end
