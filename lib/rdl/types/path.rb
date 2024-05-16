require_relative 'type'

module RDL::Type


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

    ## Represents a conjunction of paths.
    #class PathAnd < Path
    #    attr_accessor :paths

    #    def initialize(paths)
    #        @paths = paths
    #    end
    #end

    class PathType < Type
        # :condition is a RDL::Type
        # Pi = Path Condition
        # This should be an "interpretable" expression
        # that evaluates to a *type*.
        # Note that this condition can evaluate to a boolean,
        # and the map can contain `TrueClass` and `FalseClass`.
        attr_accessor :condition

        attr_accessor :loc
        attr_accessor :str

        # Map between the result of the condition expression
        # and the type of this object.
        # Map<Type, Type>
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

        # Returns a Map<Array<Path>, Type>
        def type_map
            #Here we need to turn our @condition and @map into a
            # Map<Array<Path>, Type>

            # @condition : type
            # @map : Map<Type, Type>
            tguard = @condition
            new_map = {}
            @map.each { |tmatch, tres|
                pi = PathCondition.new(tguard, tmatch, @loc, @str)
                new_map[Path.new([pi])] = tres
            }

            new_map
        end

        # path : Path[]
        def index(path)
            #TODO(Mark): this may not work.
            # k = Path[]
            matching_entries = @map.filter { |k, v| path.conds.include?(k) }
            matching_values = matching_entries.values
            RDL::Type::UnionType.new(*matching_values)
        end

        # path : Path
        def can_index?(path)
            self.type_map.keys.any? { |p| PathCondition.can_index?(path, p) }
        end

        def inspect
            return "#{"PathType".colorize(:blue)}{condition=#{@condition.to_s.colorize(:yellow)}, str=#{@str.to_s.colorize(:yellow)}, #{@map.each_pair.map { |tmatch, v| "#{tmatch.to_s.colorize(:red)} => #{v}"}.join(", ") }}"
        end

        # to_s is just like #inspect but without the colors.
        def to_s
            return "#{"PathType"}{condition=#{@condition.to_s}, str=#{@str.to_s}, #{@map.each_pair.map { |tmatch, v| "#{tmatch.to_s} => #{v}"}.join(", ") }}"
        end

        def ==(other)
            return false if other.nil?
            other = other.canonical
            return (other.instance_of? PathType) && (other.condition == @condition) && (other.map == @map)
        end

        alias eql? ==

        def instantiate(inst)
            canonicalize!
            return @canonical.instantiate(inst) if @canonical
            return PathType.new(@condition, @map.transform_values { |v| v.instantiate(inst) }, @loc, @str)
        end

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

        def copy
            PathType.new(@condition.copy, @map.clone, @loc, @str)
        end

    end
end