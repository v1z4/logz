require "logz/version"
require "logz/multi_io"
require "logz/multi_logger"

module Logz
  def self.new(*params)
    MultiLogger.new(*params)
  end
end
