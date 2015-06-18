module RDL
  class Debug
    DEBUG_LEVELS = {off: 0, info: 1, warn: 2, all: 3}
    @@debug_level = :all  # valid levels as above

    def self.debug(msg, level)
      puts msg if (DEBUG_LEVELS[level] <= DEBUG_LEVELS[@@debug_level])
    end
  end
end

