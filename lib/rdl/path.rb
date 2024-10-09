# A list of PathConditions. Delta in the formalism.
# Paths are immutable.

# TODO(Mark): PERFORMANCE: cache the result of to_s methods.
# Paths are immutable, and so are their string representations.

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
    # to_z3
    # eql?
    # ==
    # hash

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

    def to_z3
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

    def satisfiable?
        false
    end

    def inspect
        "#{"false".colorize(:red)}"
    end

    def to_s
        "false"
    end

    def to_z3
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

    def to_z3
        "v#{hash}".slice(0,4)
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

# A Path denoting that an exception has been caught anywhere in the method.
# Only used in conjunction with the `return` statement to track rescue'd 
# returns.
class PathException < Path
    def initialize
    end

    def clone
        self
    end

    def to_s
        "exn"
    end

    def inspect
        "exn"
    end

    def to_z3
        "exn"
    end

    def ==(other)
        other.is_a? PathException
    end
    alias :eql? :==
    def hash
        7213415356
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
        if paths.length == 1
            return paths[0]
        end

        # Flatten nested ANDs.
        paths = paths.flat_map { |p| 
            if p.is_a?(PathAnd)
                p.paths
            else
                p
            end
        }

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


            ## Complement (A ∧ ¬A) = false
            complements = paths.any? { |p1|
                paths.any? { |p2| 
                    p2.is_a?(PathNot) && p2.path == p1
                }
            }
            if complements
                return PathFalse.new
            end

            #if paths.length == 2 && ((paths[0].is_a?(PathNot) && paths[0].path == paths[1]) || (paths[1].is_a?(PathNot) && paths[1].path == paths[0]))
            #    return PathFalse.new
            #end

            ## (A ∧ B) ∧ A = (A ∧ B)
            ## (B ∧ A) ∧ A = (B ∧ A)
            #if paths.length == 2 && paths[0].is_a?(PathAnd) && paths[0].paths.length == 2 && (paths[0].paths[0] == paths[1] || paths[0].paths[1] == paths[1])
            #    return paths[0]
            #end

            ## A ∧ (A ∧ B) = (A ∧ B)
            ## A ∧ (B ∧ A) = (B ∧ A)
            #if paths.length == 2 && paths[1].is_a?(PathAnd) && paths[1].paths.length == 2 && (paths[1].paths[0] == paths[0] || paths[1].paths[1] == paths[0])
            #    return paths[1]
            #end

            ## A ∧ (¬A ∧ B) = false
            #if paths.length == 2 && (paths[1].is_a?(PathAnd) && (paths[1].paths[0].is_a?(PathNot) && paths[1].paths[0].path == paths[0]))
            #    return PathFalse.new
            #end

            ## A ∧ (B ∧ ¬A) = false
            #if paths.length == 2 && (paths[1].is_a?(PathAnd) && (paths[1].paths[1].is_a?(PathNot) && paths[1].paths[1].path == paths[0]))
            #    return PathFalse.new
            #end

            ## ¬A ∧ (A ∧ B) = false
            #if paths.length == 2 && (paths[1].is_a?(PathAnd) && (paths[0].is_a?(PathNot) && paths[1].paths[0] == paths[0].path))
            #    return PathFalse.new
            #end

            ## ¬A ∧ (B ∧ A) = false
            #if paths.length == 2 && (paths[1].is_a?(PathAnd) && (paths[0].is_a?(PathNot) && paths[1].paths[1] == paths[0].path))
            #    return PathFalse.new
            #end

            ## (A ∧ B) ∧ ¬A  = false
            #if paths.length == 2 && (paths[0].is_a?(PathAnd) && (paths[1].is_a?(PathNot) && paths[0].paths[0] == paths[1].path))
            #    return PathFalse.new
            #end

            # Ok. Need some better rules here. 
            # When there is an arbitrarily nested amount of PathAnds, 
            #just flatten them. 
            #And check to see if an element appears in both its regular form and NOT form
            # Or even better, just flatten them by construction.
            # Then, these rules get a lot easier.
            # Just need to figure out how to write that rule. for a pathand with n conjunctions.
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

    def to_z3
        "(and #{paths.map(&:to_z3).join(" ")})"
    end

    # Define `eql?` and `hash` so this can be used a hash key
    def ==(other)
        (other.is_a? PathAnd) && @paths == other.paths
    end
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

            ## (A ∧ B) ∨ (A ∧ ¬B) = A but for large conjunctions
            if paths.length == 2 && paths[0].is_a?(PathAnd) && paths[1].is_a?(PathAnd)
                # Make sure they differ by a single element
                diff = (paths[0].paths + paths[1].paths) - (paths[0].paths & paths[1].paths)
                if diff.size == 2 && ((diff[0].is_a?(PathNot) && diff[0].path == diff[1]) || (diff[1].is_a?(PathNot) && diff[1].path == diff[0]))
                    # Return A (except it may be a conjunction of many things)
                    return PathAnd.new(paths[0].paths - diff)
                end

            end


            ## (A ∧ B) ∨ (A ∧ ¬B) = A and all variations
            #if paths.length == 2
            #    path1, path2 = paths
            
            #    if path1.is_a?(PathAnd) && path2.is_a?(PathAnd)
            #        a1, b1 = path1.paths
            #        a2, b2 = path2.paths
            #    
            #        # Case 1: (A && B) || (A && !B)
            #        if a1 == a2 && ((b1.is_a?(PathNot) && b1.path == b2) || (b2.is_a?(PathNot) && b2.path == b1))
            #            return a1
            #        end
            #    
            #        # Case 2: (A && B) || (!B && A)
            #        if a1 == b2 && ((b1.is_a?(PathNot) && b1.path == a2) || (a2.is_a?(PathNot) && a2.path == b1))
            #            return a1
            #        end
            #    
            #        # Case 3: (B && A) || (A && !B)
            #        if b1 == a2 && ((a1.is_a?(PathNot) && a1.path == b2) || (b2.is_a?(PathNot) && b2.path == a1))
            #            return a2
            #        end
            #    
            #        # Case 4: (B && A) || (!B && A)
            #        if b1 == b2 && ((a1.is_a?(PathNot) && a1.path == a2) || (a2.is_a?(PathNot) && a2.path == a1))
            #            return b2
            #        end
            #    end
            #end
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

    def to_z3
        "(or #{paths.map(&:to_z3).join(" ")})"
    end

    # Define `eql?` and `hash` so this can be used a hash key
    def ==(other)
        (other.is_a? PathOr) && @paths == other.paths
    end
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

    def to_z3
        "(not #{@path.to_z3})"
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
