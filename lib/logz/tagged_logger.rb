module Logz
  class TaggedLogger
    attr_accessor :logger

    def initialize(logger)
      @logger = Logger.new(logger)
      @tags = ''
    end

    def tagged(tags)
      @tags = tags.map do |e| 
        tag = e.gsub(/\[\]/, '').upcase
        "[#{tag}]"
      end.join(' ')

      self
    end

    def debug(msg)
      logger.debug tagged_message(msg)
    end

    def info(msg)
      logger.info tagged_message(msg)
    end

    def warn(msg)
      logger.warn tagged_message(msg)
    end

    def error(msg)
      logger.error tagged_message(msg)
    end

    def fatal(msg)
      logger.fatal tagged_message(msg)
    end

    def method_missing(m, *args, &block)
      if logger.respond_to?(m)
        logger.send(m, *args)
      else
        super
      end
    end

    private

    def tagged_message(msg)
      @tags.empty? ? msg : "#{@tags} #{msg}"
    end

  end
end