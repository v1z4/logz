require 'logger'
require 'logz/version'
require 'logz/multi_io'
require 'logz/multi_logger'

module Logz
  class Configuration
    attr_accessor :folder, :output_to_stdout, :output_to_file,
                  :default, :suffix, :prefix, :loggers, :extension

    def initialize
      @output_to_stdout = true
      @output_to_file = true
      @default = 'stdout'
      @folder = 'log'
      @extension = 'log'
      @loggers = []
      @suffix = ''
      @prefix = ''
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.new(*params)
    configure
    MultiLogger.new(*params)
  end
  
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)  if block_given?
  end
end