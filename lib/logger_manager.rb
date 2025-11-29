require 'logger'
require 'fileutils'
require_relative 'my_application_davydenko'

module MyApplicationDavydenko
  class LoggerManager
    class << self
      def setup(cfg)
        cfg = cfg['logging']
        dir = cfg['directory']
        FileUtils.mkdir_p(dir)

        @log  = Logger.new(File.join(dir, cfg['files']['application_log']))
        @elog = Logger.new(File.join(dir, cfg['files']['error_log']))

        level = cfg['level'].upcase
        @log.level  = Logger.const_get(level)
        @elog.level = Logger.const_get(level)
      end

      def log_processed_file(path)
        @log.info("Processed file: #{path}")
      end

      def log_error(msg)
        @elog.error(msg)
      end
    end
  end
end