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
        # Pi = Path
        # This should be an "interpretable" expression
        # that evaluates to a *type*.
        # Note that this condition can evaluate to a boolean,
        # and the map can contain `TrueClass` and `FalseClass`.
        attr_accessor :condition

        # Map between the result of the condition expression
        # and the type of this object.
        # Map<Type, Type>
        attr_accessor :when_true
        attr_accessor :when_false

        def initialize(condition, when_true, when_false)
            @condition = condition
            @when_true = when_true
            @when_false = when_false

            # NOTE(Mark): Once we figure out the format of `condition`,
            #             add a validation here.
            raise RuntimeError, "Path condition must be a Path" if !condition.is_a? Path
            raise RuntimeError, "when_true must be a Type" if !when_true.is_a? RDL::Type::Type
            raise RuntimeError, "when_false must be a Type" if !when_false.is_a? RDL::Type::Type
        end

        ## Returns a Map<Array<Path>, Type>
        #def type_map
        #    #Here we need to turn our @condition and @map into a
        #    # Map<Array<Path>, Type>

        #    # @condition : type
        #    # @map : Map<Type, Type>
        #    tguard = @condition
        #    new_map = {}
        #    @map.each { |tmatch, tres|
        #        pi = PathCondition.new(tguard, tmatch, @loc, @str)
        #        new_map[Path.new([pi])] = tres
        #    }

        #    new_map
        #end

        ## path : Path[]
        #def index(path)
        #    #TODO(Mark): this may not work.
        #    # k = Path[]
        #    matching_entries = @map.filter { |k, v| path.conds.include?(k) }
        #    matching_values = matching_entries.values
        #    RDL::Type::UnionType.new(*matching_values)
        #end

        ## path : Path
        #def can_index?(path)
        #    self.type_map.keys.any? { |p| PathCondition.can_index?(path, p) }
        #end

        def index(path)
            if path == @condition
                return @when_true
            end
            if (path.is_a? PathNot) && path.path == @condition
                return @when_false
            end
            throw "cannot index"
        end
        def can_index?(path)
            (path == @condition) || ((path.is_a? PathNot) && path.path == @condition)
        end

        def inspect
            return "#{"PathType".colorize(:blue)}{condition=#{@condition.to_s.colorize(:yellow)}, when_true => #{@when_true.inspect}, when_false => #{@when_false.inspect}}"
        end

        # to_s is just like #inspect but without the colors.
        def to_s
            return "#{"PathType"}{condition=#{@condition.to_s}, when_true => #{@when_true.to_s}, when_false => #{@when_false.to_s}}"
        end

        def ==(other)
            return false if other.nil?
            other = other.canonical
            return (other.instance_of? PathType) && (other.condition == @condition) && (other.when_true == @when_true) && (other.when_false == @when_false)
        end

        alias eql? ==

        def instantiate(inst)
            canonicalize!
            return @canonical.instantiate(inst) if @canonical
            return PathType.new(@condition, @when_true.instantiate(inst), @when_false.instantiate(inst))
        end

        def canonical
            canonicalize!
            return @canonical if @canonical
            return self
        end

        def canonicalize!
            return if @canonicalized
            # NOTE(Mark): This impl should be similar to Union
            # TODO(Mark): implement
            #@map.transform_values! {|type| type.canonical}

            ## The point of a path type is to distinguish between different
            ## types depending on the path conditions.
            ## If the types we're distinguishing against, are all the same,
            ## there is no need to have a path type. 
            ## (e.g. PathType{cond=..., TrueClass => %bot, FalseClass => %bot} 
            ##  is just %bot)
            #if @map.values.all? { |guard| guard == @map.values[0] }
            #    @canonical = @map.values[0]
            #end

            #@canonicalized = true
        end

        def copy
            PathType.new(@condition.copy, @when_true.copy, @when_false.copy)
        end

    end
end