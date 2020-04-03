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
      @color = color_name.to_sym
      self
    end

    # logger.tag(user_id: 1).info("foo")
    # logger.tag("user is nil").error("bar")
    # logger.tag(["a", "b"]).debug("bar")
    def tag(tags)
      if tags.is_a?(Hash)
        @tags << tags.map { |k, v| "[#{k.to_s.upcase}=#{v}]" }.join(" ")
      elsif tags.is_a?(Array)
        @tags << tags.map { |v| "[#{v.to_s}]" }.join(" ")
      else
        @tags << "[#{tags.to_s}]"
      end

      @tags.uniq!

      self
    end
    alias_method :tagged, :tag

    def has_level?(level)
      Logz.config.levels.include?(level)
    end

    def add(severity, message = nil, progname = nil)
      severity = Logger.const_get(severity.upcase) if severity.is_a?(Symbol)
      logger.send(:add, severity, to_output(message), progname)
    ensure
      reset
    end

    alias_method :tag, :tagged

    def method_missing(m, *args, &block)
      if has_level?(m)
        add(m, *args)
      elsif logger.respond_to?(m)
        logger.send(m, *args)
      elsif Rainbow::X11ColorNames::NAMES.include?(m)
        color(m)
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
