module Logz
  class MultiLogger
    include Enumerable
    attr_accessor :folder, :loggers

    def initialize(folder = nil, loggers: [])
      @folder = set_folder(folder)
      @loggers = {}
      Logz.config.loggers.dup.push(*loggers).each { |name| add(name) }
    end

    def add(name, path = '', to_stdout: Logz.config.output_to_stdout, to_file: Logz.config.output_to_file)
      if name.is_a?(Array)
        name.each { |log| add(log, path, to_stdout: to_stdout, to_file: to_file) }
      elsif name == STDOUT || name.to_s == 'stdout'
        @loggers[:stdout] = TaggedLogger.new(STDOUT)
      else
        output_stream = set_output_stream(name, path, to_stdout, to_file)
        @loggers[name.to_sym] = TaggedLogger.new(output_stream)
      end
    end

    def <<(name, path = '', to_stdout: nil, to_file: nil)
      add(name, path, to_stdout: to_stdout, to_file: to_file)
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
      loggers[:stdout]
    end

    def method_missing(m, *args, &block)
      if loggers.has_key?(m)
        if args.empty?
          loggers[m]
        else
          puts "Invalid method for logger '#{m}': #{args.join(', ')}"
        end
      elsif default_logger.respond_to?(m)
        default_logger.send(m, *args, &block)
      else
        puts "Logger '#{m}' not found. Current loggers: #{loggers.keys.join(', ')}"
      end
    end

    private

    def set_folder(folder = Logz.config.folder)
      dir = if !folder || folder.empty? || folder == '.' || folder == './'
              Dir.pwd
            elsif folder.start_with?('/')
              folder
            else
              File.join(Dir.pwd, folder)
            end

      dir.tap { |d| FileUtils.mkdir_p(d)  unless File.directory?(d)  }
    end

     def set_output_stream(name, path, to_stdout, to_file)
      if to_file
        log_path = set_log_path(name, path)
        log_file = File.open(log_path, 'a+')

        to_stdout ? MultiIO.new(STDOUT, log_file) : log_file
      elsif to_stdout
        STDOUT
      else
        '/dev/null'
      end
    end

    def set_log_path(name, path)
      file_extension = Logz.config.extension.to_s.strip.empty? ? '' : ".#{Logz.config.extension}"
      log_folder_path = path.start_with?('/') ? path : File.join(folder, path)
      log_file_path = "/#{Logz.config.prefix}#{name}#{Logz.config.suffix}#{file_extension}"

      File.join(log_folder_path, log_file_path)
    end

  end
end
