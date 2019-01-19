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

    def add(name, path = '', prefix: '', to_stdout: false, to_file: true)
      if name.is_a?(Array)
        name.each { |n| add(n, path, prefix: prefix, to_stdout: to_stdout, to_file: to_file) }
      else
        output = if to_stdout && to_file
                  log_path = set_log_path(path, name, prefix: prefix)
                  MultiIO.new(STDOUT, File.open(log_path, 'a+'))
                elsif to_stdout
                  STDOUT
                elsif to_file
                  log_path = set_log_path(path, name, prefix: prefix)
                end
        @loggers[name.to_sym] = Logger.new(output)
      end
    end

    def <<(name, path = '', prefix = '')
      add(name, path, prefix: prefix)
    end

    def each
      loggers.each do |name, logger|
        yield(logger)
      end
    end

    def [](name)
      loggers[name.to_sym]
    end

    def global_level=(level)
      loggers.each { |name, logger| logger.level = level }
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

    def set_log_path(path, name, prefix: '')
      log_path = path.starts_with?('/') ? path : folder + '/' + path
      log_path << "/#{name}#{prefix}.log"
    end

  end
end
