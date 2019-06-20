module Logz
  class MultiLogger
    include Enumerable
    attr_accessor :folder, :loggers

    def initialize(folder = nil)
      @folder = set_folder(folder)
      @loggers = {}

      FileUtils.mkdir_p(@folder)  unless File.directory?(@folder)

      add(Logz.configuration.default)
      Logz.configuration.loggers.each { |logger_name| add(logger_name) }  if Logz.configuration.loggers.any?
    end

    def add(name, path = '', to_stdout: nil, to_file: nil)
      to_stdout = Logz.configuration.output_to_stdout  if to_stdout == nil
      to_file   = Logz.configuration.output_to_file    if to_file == nil

      if !name || name.empty?
        return false
      elsif name == STDOUT || name == 'stdout'
        name = 'stdout'
        to_stdout = true
        to_file = false
      end

      if name.is_a?(Array)
        name.each { |n| add(n, path, to_stdout: to_stdout, to_file: to_file) }
      else
        log_path      = set_log_path(path, name)
        output_stream = set_output_stream(log_path, to_stdout, to_file)

        @loggers[name.to_sym] = Logger.new(output_stream)
      end
    end

    def <<(name, path = '')
      add(name, path)
    end

    def remove(name)
      @loggers[name.to_sym].close
      @loggers.delete(name.to_sym)
    end
    alias_method :delete, :remove

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

    def default_logger
      loggers[Logz.configuration.default&.to_sym]
    end

    def method_missing(m, *args, &block)
      if loggers.has_key?(m)
        if args.empty?
          loggers[m]
        else
          puts "Invalid method for logger '#{m}': #{args.join(', ')}"
        end
      elsif default_logger.respond_to?(m)
        default_logger.send(m, *args)
      else
        puts "Logger '#{m}' not found. Current loggers: #{loggers.keys.join(', ')}"
      end
    end

    private

    def set_folder(folder)
      folder ||= Logz.configuration.folder

      if !folder || folder.empty? || folder == '.' || folder == './'
        Dir.pwd
      elsif folder.start_with?('/')
        folder
      else
        File.join(Dir.pwd, folder)
      end
    end

    def set_log_path(path, name)
      file_extension = Logz.configuration.extension.to_s.strip.empty? ? '' : ".#{Logz.configuration.extension}"
      log_folder_path = path.start_with?('/') ? path : File.join(folder, path)
      log_file_path = "/#{Logz.configuration.prefix}#{name}#{Logz.configuration.suffix}#{file_extension}"

      File.join(log_folder_path, log_file_path)
    end

    def set_output_stream(log_path, to_stdout, to_file)
      if to_stdout && to_file
        MultiIO.new(STDOUT, File.open(log_path, 'a+'))
      elsif to_stdout
        STDOUT
      elsif to_file
        File.open(log_path, 'a+')
      else
        '/dev/null'
      end
    end

  end
end
