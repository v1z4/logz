require "logger"
require "fileutils"
require "logz/version"
require "logz/multi_io"
require "logz/multi_logger"
require "logz/tagged_logger"

module Logz
  class Config
    attr_accessor :folder, :output_to_stdout, :output_to_file,
                  :suffix, :prefix, :loggers, :extension

    def initialize
      @output_to_stdout = true
      @output_to_file = true
      @folder = "log"
      @extension = "log"
      @loggers = [:stdout]
      @suffix = ""
      @prefix = ""
    end
  end

  class << self
    attr_accessor :config
  end

  def self.new(*params)
    configure
    MultiLogger.new(*params)
  end

  def self.configure
    self.config ||= Config.new
    yield(config) if block_given?
  end
end
