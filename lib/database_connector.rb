require_relative 'logger_manager'

module MyApplicationDavydenko
  class DatabaseConnector
    attr_reader :db

    def initialize(config)
      # читаємо структуру з default_config.yaml
      @db_config     = config['database_config'] || {}
      @sqlite_config = @db_config['sqlite_database'] || {}
      @mongo_config  = config['mongodb_database'] || {}
      @db = nil
    end

    def connect_to_database
      db_type = @db_config['database_type']

      case db_type
      when 'sqlite'
        connect_to_sqlite
      when 'mongodb'
        connect_to_mongodb
      else
        MyApplicationDavydenko::LoggerManager.log_error(
          "Unsupported database type: #{db_type}"
        )
        nil
      end
    rescue StandardError => e
      MyApplicationDavydenko::LoggerManager.log_error(
        "Database connection error: #{e.message}"
      )
      nil
    end

    def close_connection
      MyApplicationDavydenko::LoggerManager.log_processed_file("Database connection closed")
      @db = nil
    end

    private

    def connect_to_sqlite
      MyApplicationDavydenko::LoggerManager.log_error(
        "SQLite is not available on this system, skipping connection"
      )
      nil
    end

    def connect_to_mongodb
      MyApplicationDavydenko::LoggerManager.log_error(
        "MongoDB driver is not installed, skipping connection"
      )
      nil
    end
  end
end
