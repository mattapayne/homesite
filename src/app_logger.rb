require 'logger'

module MattPayne
  
  class AppLogger
    
    class << self
      
      LEVEL = Logger::INFO
      LOG_TO = "application.log"
      
      attr_accessor :level, :log_to
      
      def configure(&block)
        block.call(self) if block_given?
      end
      
      def info(msg)
        logger.info(msg)
      end
      
      def error(msg)
        logger.error(msg)
      end
      
      def warn(msg)
        logger.warn(msg)
      end
      
      def debug(msg)
        logger.debug(msg)
      end
      
      def fatal(msg)
        logger.fatal(msg)
      end
      
      private
      
      def logger
        @logger ||= (
          l = Logger.new(log_destination)
          l.level = LEVEL
          l
        )
      end
      
      def log_destination
        return STDOUT if [:development, :test].include?(Sinatra::Application.environment)
        return LOG_TO
      end
      
    end
    
  end
  
end
