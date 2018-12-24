module Logz
  class MultiLogger
    include Enumerable
    attr_accessor :folder, :loggers

    def initialize(folder = nil)
      if folder
        @folder = folder.starts_with?('/') ? folder : (Dir.pwd + '/' + folder)
      else
        @folder = Dir.pwd
      end
      @loggers = {}
      @loggers[:default] = Logger.new(STDOUT)
    end

    def add(name, path = '')
      if name.is_a?(Array)
        name.each { |n| add(n) }
      else
        log_path = set_log_path(path, name)
        @loggers[name.to_sym] = Logger.new(log_path)
      end
    end

    def <<(name, path = '')
      add(name, path)
    end

    def add_dual(name, path = '')
      if name.is_a?(Array)
        name.each { |n| add_dual(n) }
      else
        log_path = set_log_path(path, name)
        multi_io = MultiIO.new(STDOUT, File.open(log_path, "a+"))
        @loggers[name.to_sym] = Logger.new(multi_io)
      end
    end

    def each
      loggers.each do |name, logger|
        yield(logger)
      end
    end

    def [](name)
      loggers[name.to_sym]
    end

    def method_missing(m, *args, &block)
      if loggers[:default].respond_to?(m)
        loggers[:default].send(m, *args)
      elsif loggers.has_key?(m)
        loggers[m]
      else
        raise "Logz: can't delegate method to loggers: #{m}"
      end
    end

    private

    def set_log_path(path, name)
      log_path = path.starts_with?('/') ? path : folder + '/' + path
      log_path << "/#{name}.log"
    end

  end
end
