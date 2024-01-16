require_relative 'type'

module RDL::Type
    # Represents the actual path condition 
    # (a single constraint in Delta in the formalism)
    class Path
        attr_accessor :tguard
        attr_accessor :tmatch
        attr_accessor :loc
        attr_accessor :str

        def initialize(tguard, tmatch, loc, str)
            @tguard = tguard
            @tmatch = tmatch

            @loc = loc
            @str = str
        end

        def to_s
            "#{"Path".colorize(:green)}{tguard=#{tguard.to_s.colorize(:yellow)}, tmatch=#{tmatch.to_s.colorize(:red)}, str=#{str.colorize(:grey)}}"
        end
        alias_method :inspect, :to_s

    end

    ## NOTE(Mark): This is temporary.
    #class Equality < RDL::Type::SingletonType
    #    attr_accessor :lhs
    #    attr_accessor :rhs
    #    attr_accessor :loc

    #    # lhs = 
    #    # rhs = 
    #    # loc = 
    #    def initialize(lhs, rhs, loc)
    #        @lhs = lhs
    #        @rhs = rhs
    #        @loc = loc
    #    end
    #end

    # Represents a conjunction of paths.
    class PathAnd < Path
        attr_accessor :paths

        def initialize(paths)
            @paths = paths
        end
    end

    class PathType < Type
        # Pi = Path Condition
        # This should be an "interpretable" expression
        # that evaluates to a *type*.
        # Note that this condition can evaluate to a boolean,
        # and the map can contain `TrueClass` and `FalseClass`.
        attr_accessor :condition

        # Map between the result of the condition expression
        # and the type of this object.
        attr_accessor :map

        def initialize(condition, map, loc, str)
            @condition = condition
            @map = map
            @loc = loc
            @str = str

            # NOTE(Mark): Once we figure out the format of `condition`,
            #             add a validation here.
            raise RuntimeError, "Path condition must be a type" if !condition.is_a? Type
            raise RuntimeError, "Path map must be a Hash" if !map.is_a? Hash
            raise RuntimeError, "Path map must not be empty" if map.values.length < 1
        end

        def to_s
            return "#{"PathType".colorize(:blue)}{condition=#{@condition.to_s.colorize(:yellow)}, str=#{@str.to_s.colorize(:yellow)}, #{@map.each_pair.map { |tmatch, v| "#{tmatch.to_s.colorize(:red)} => #{v}"}.join(", ") }}"
        end
        alias_method :inspect, :to_s

        def ==(other)
            return false if other.nil?
            other = other.canonical
            return (other.instance_of? PathType) && (other.condition == @condition) && (other.map == @map)
        end

        alias eql? ==

        def canonical
            canonicalize!
            return @canonical if @canonical
            return self
        end

        def canonicalize!
            return if @canonicalized
            # NOTE(Mark): This impl should be similar to Union
            @map.transform_values! {|type| type.canonical}

            # The point of a path type is to distinguish between different
            # types depending on the path conditions.
            # If the types we're distinguishing against, are all the same,
            # there is no need to have a path type. 
            # (e.g. PathType{cond=..., TrueClass => %bot, FalseClass => %bot} 
            #  is just %bot)
            if @map.values.all? { |guard| guard == @map.values[0] }
                @canonical = @map.values[0]
            end

            @canonicalized = true
        end

    end
end