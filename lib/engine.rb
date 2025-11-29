require 'fileutils'
require_relative 'logger_manager'
require_relative 'database_connector'
require_relative 'simple_website_parser'

module MyApplicationDavydenko
  class Engine
    def initialize(config)
      @config = config
      @items  = nil
    end

    def run(params)

      MyApplicationDavydenko::LoggerManager.setup(@config)

      db_connector = MyApplicationDavydenko::DatabaseConnector.new(@config)
      db = db_connector.connect_to_database

      params.each do |method_name, flag|
        next unless flag == 1
        send(method_name) if respond_to?(method_name, true)
      end

      db_connector.close_connection if db
    end

    private

    def run_website_parser
      parser = MyApplicationDavydenko::SimpleWebsiteParser.new(@config)
      parser.start_parse
      @items = parser.item_collection
    end

    def run_save_to_csv
      @items&.save_to_csv('output/items.csv')
    end

    def run_save_to_json
      @items&.save_to_json('output/items.json')
    end

    def run_save_to_yaml
      @items&.save_to_yml('output/yml_items')
    end

    def run_save_media
      return unless @items

      project_root = File.expand_path('..', __dir__)
      target_dir   = File.join(project_root, 'output', 'media')
      FileUtils.mkdir_p(target_dir)

      @items.each do |item|
        next unless item.respond_to?(:image_path) && item.image_path

        src = File.join(project_root, item.image_path) # наприклад "media/ps5/xxx.jpg"
        next unless File.exist?(src)

        filename = File.basename(src)
        FileUtils.cp(src, File.join(target_dir, filename))
      end

      puts 'Media files copied to output/media'
    end

    def run_save_to_sqlite
      puts 'run_save_to_sqlite called (stub)'
    end

    def run_save_to_mongodb
      puts 'run_save_to_mongodb called (stub)'
    end
  end
end
