module Logz
  class LoggerWrapper
    attr_accessor :logger

    def initialize(logger)
      @logger = Logger.new(logger)
      reset
    end

    def reset
      @tags = []
      @color = nil
    end

    def color(color_name)
      @color = color_name
      self
    end

    # user_id: 1
    def tagged(tags)
      if tags.is_a?(Hash)
        @tags << tags.map { |k, v| "[#{k&.upcase}=#{v}]" }.join(" ")
      elsif tags.is_a?(Array)
        @tags << tags.map { |v| "[#{v&.upcase}]" }.join(" ")
      else
        @tags << "[#{tags.to_s&.upcase}]"
      end

      self
    end

    def has_level?(level)
      Logz.config.levels.include?(level)
    end

    alias_method :tag, :tagged

    def method_missing(m, *args, &block)
      if has_level?(m)
        logger.send(m, to_output(args.first))
        reset
      elsif logger.respond_to?(m)
        logger.send(m, *args)
      elsif Rainbow::X11ColorNames::NAMES.include?(m)
        @color = m.to_sym
        self
      else
        super
      end
    end

    private

    def to_output(msg)
      output = @tags.empty? ? msg : "#{@tags.join(" ")} #{msg}"
      output = @color ? Rainbow(output).color(@color.to_sym) : output
    end
  end
end
