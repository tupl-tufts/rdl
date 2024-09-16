# A list of PathConditions. Delta in the formalism.
# Paths are immutable.

class Path

    def initialize
        puts "about to crash"
        throw "do not instantiate Path"
    end

    # All Paths should implement (at a minimum):
    # a constructor
    # clone
    # inspect
    # to_s

    def satisfiable?
        true
    end

    # Define `eql?` and `hash` so this can be used a hash key
    alias :eql? :==
    def hash
        13587013857
    end
end

class PathTrue < Path

    def initialize
    end

    def clone
        PathTrue.new
    end

    def inspect
        "#{"true".colorize(:green)}"
    end

    def to_s
        "true"
    end

    # Define `eql?` and `hash` so this can be used a hash key
    def ==(other)
        other.is_a? PathTrue
    end
    alias :eql? :==
    def hash
        89726108746914
    end
end

class PathFalse < Path

    def initialize
    end

    def clone
        PathFalse.new
    end

    def inspect
        "#{"false".colorize(:red)}"
    end

    def to_s
        "false"
    end

    # Define `eql?` and `hash` so this can be used a hash key
    def ==(other)
        other.is_a? PathFalse
    end
    alias :eql? :==
    def hash
        786324586732457864523
    end
end

# Represents a single Path Condition (i.e. observed subtype of a variable)
class PathCondition < Path
    attr_reader :tguard # RDL::Type
    attr_reader :tmatch # RDL::Type
    attr_reader :loc    # AST Location
    attr_reader :str    # String representation of guard expression

    def initialize(tguard, tmatch, loc, str)
        throw "tguard must be RDL::Type, got #{tguard.class}" unless tguard.class <= RDL::Type::Type
        throw "tmatch must be RDL::Type, got #{tmatch.class}" unless tmatch.class <= RDL::Type::Type
        throw "str must be String, got #{str.class}" unless str.class <= String

        @tguard = tguard
        @tmatch = tmatch
        @loc = loc
        @str = str
    end

    def clone
        PathCondition.new(@tguard, @tmatch, @loc, @str)
    end

    def inspect
        # compact
        "{#{str.colorize(:grey)} => #{tmatch.to_s.colorize(:red)}}"
    end

    # to_s is just like #inspect but without the colors.
    def to_s
        # compact
        "{#{str} => #{tmatch.to_s}}"
    end

    # Define `eql?` so this can be used a hash key
    def ==(other)
        (other.is_a? PathCondition) && (other.tguard == @tguard) && (other.tmatch == @tmatch) && (other.loc == @loc) && (other.str == @str)
    end
    alias :eql? :==
    def hash
        tguard.hash * tmatch.hash * loc.hash * str.hash * 13
    end
end

class PathAnd < Path
    attr_reader :paths # List<Path>

    class << self
      alias :__new__ :new
    end

    def self.new(paths)
        throw "paths must be a List, got: #{paths.class}" unless paths.class <= Array
        throw "paths must be a List of Paths, got list of: #{paths[0].class}" unless paths.all? { |p| p.class <= Path }
        if paths.length() == 0
            throw "can't AND 0 paths"
        end

        if RDL::Config.instance.boolean_algebra
            # Annulment (A ∧ False) = False
            if paths.any? { |p| p.class <= PathFalse }
                return PathFalse.new
            end

            # Identity (A ∧ True) = A
            paths = paths.filter { |p| !(p.class <= PathTrue) }

            # If we filtered out all paths (i.e. they are all true), return true
            if paths.length == 0
                return PathTrue.new
            end

            # Idempotency (A ∧ A) = A
            if paths.uniq.size == 1
                return paths[0]
            end
        end

        if paths.length == 1
            return paths[0]
        end

        PathAnd.__new__(paths)
    end

    def initialize(paths)
        @paths = paths
    end

    def inspect
        "{#{paths.map(&:inspect).join(" ∧ ")}}"
    end

    def to_s
        "{#{paths.map(&:to_s).join(" ∧ ")}}"
    end

    # Define `eql?` and `hash` so this can be used a hash key
    alias :eql? :==
    def hash
        @paths.map(&:hash).reduce(:*) * 729
    end
end

class PathOr < Path
    attr_reader :paths # List<Path>

    class << self
      alias :__new__ :new
    end

    def self.new(paths)
        throw "paths must be a List, got: #{paths.class}" unless paths.class <= Array
        throw "paths must be a List of Paths, got list of: #{paths[0].class}" unless paths.all? { |p| p.class <= Path }
        if paths.length() == 0
            throw "can't OR 0 paths"
        end

        if RDL::Config.instance.boolean_algebra
            # Annulment (A ∨ True) = True
            if paths.any? { |p| p.class <= PathTrue }
                return PathTrue.new
            end

            # Identity (A ∨ False) = A
            paths = paths.filter { |p| !(p.class <= PathFalse) }

            # If we filtered out all Paths (i.e. they are all false), return false.
            if paths.length == 0
                return PathFalse.new
            end

            # Complement (A ∨ ¬A) = True
            if paths.length == 2
                test = nil
                negatedTest = nil

                if (paths[0].class <= PathNot) && !(paths[1].class <= PathNot)
                    negatedTest = paths[0]
                    test = paths[1]
                elsif (paths[1].class <= PathNot) && !(paths[0].class <= PathNot)
                    negatedTest = paths[1]
                    test = paths[0]
                end

                if test && negatedTest && (test == negatedTest.path)
                    return PathTrue.new
                end
            end

            # Idempotency (A ∨ A) = A
            if paths.uniq.size == 1
                return paths[0]
            end
        end

        if paths.length == 1
            return paths[0]
        end

        PathOr.__new__(paths)
    end

    def initialize(paths)
        @paths = paths
    end

    def inspect
        "{#{paths.map(&:inspect).join(" ∨ ")}}"
    end

    def to_s
        "{#{paths.map(&:to_s).join(" ∨ ")}}"
    end

    # Define `eql?` and `hash` so this can be used a hash key
    alias :eql? :==
    def hash
        @paths.map(&:hash).reduce(:*) * 649
    end
end

class PathNot < Path
    attr_reader :path # Path

    class << self
      alias :__new__ :new
    end

    def self.new(path)
        throw "PathNot requires a Path, got #{path.class}" unless path.class <= Path

        if RDL::Config.instance.boolean_algebra
            if path.class <= PathTrue
                return PathFalse.new
            end
            if path.class <= PathFalse
                return PathTrue.new
            end
        end

        PathNot.__new__(path)
    end

    def initialize(path)
        @path = path
    end

    def clone
        PathNow.new @path
    end

    def inspect
        "¬#{@path.inspect}"
    end

    def to_s
        "¬#{@path.to_s}"
    end

    # Define `eql?` and `hash` so this can be used a hash key
    def ==(other)
        (other.is_a? PathNot) && @path == other.path
    end
    alias :eql? :==
    def hash
        @path.hash * 5281
    end
end
