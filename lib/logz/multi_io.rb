module Logz
  class MultiIO
    attr_reader :targets

    def initialize(*targets)
      @targets = targets
    end

    def write(*args)
      targets.each {|t| t.write(*args); t.flush }
    end

    def flush
      targets.each(&:flush)
    end

    def close
      targets.each(&:close)
    end
  end
end
