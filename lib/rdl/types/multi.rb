module RDL::Type
    class MultiType < Type
        # @map maps Paths to Types.
        attr_accessor :map

        class << self
        alias :__new__ :new
        end

        # TODO(Mark): Add a `self.new` method which can quickly
        #             determine if the path contained in the map
        #             is complete, and if so, return a PathType
        #             instead.
        def self.new(map)
            keys = map.keys
            return RDL::Globals.types[:bot] if keys.size == 0
            return map[keys[0]] if keys.size == 1

            return MultiType.__new__(map)
        end

        def initialize(map = {})
            @map = map
        end

        # placeholder
        def is_complete?
            true
        end

        # TODO: add `is_a?`, with a `pi` component. For `MP_case_generic`
        
        def to_s
            return "#{"MultiType".colorize(:blue)}{ " + @map.each_pair.map { |pi, t| "#{t}_{#{pi}}" }.join(", ") + " }"
        end
        alias_method :inspect, :to_s

    end
end