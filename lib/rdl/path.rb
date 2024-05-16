# A list of PathConditions. Delta in the formalism.
class Path
    attr_reader :conds

    # Returns a new Path with duplicate conditions removed.
    def initialize(path_conditions = [])
        if path_conditions.any? {|p| !p.is_a? PathCondition}
            raise "Path not made of path conditions"
        end
        @conds = path_conditions.uniq
    end

    # other : Path
    # Joins this path environment with another.
    # No pruning is performed besides getting rid of duplicates.
    def join(other)
        Path.new(@conds + other.conds)
    end

    def ==(other)
        other && @conds == other.conds
    end

    # Define `eql?` and `hash` so Path can be used a hash key
    alias :eql? :==
    def hash
        @conds.hash
    end

    # Performs a check to determine whether or not the conjunction
    # of these Paths is satisfiable. Do they contain contradictions?
    def satisfiable?
        # Easy (naive) solution: see what variables these conditions
        # are representing. If there are any duplicates 
        # (i.e. two conditions that reference the same variable)
        # they MUST be a contradiction. If they mapped the same var
        # to the same type, it would have been removed earlier.

        ret = @conds.map { |cond| cond.str }.uniq.length == @conds.length
        return ret
    end

    def clone
        Path.new(@conds.clone)
    end
    alias :copy :clone

    def inspect
        "[#{@conds.map(&:inspect).join(",")}]"
    end

    def to_s
        "[#{@conds.map(&:to_s).join(",")}]"
    end
end


# Represents the actual path condition 
# (a single constraint in Delta in the formalism)
class PathCondition
    attr_accessor :tguard # the type we are typetesting
    attr_accessor :tmatch # the type we have matched it to
    attr_accessor :loc    # src location
    attr_accessor :str    # string representation

    def initialize(tguard, tmatch, loc, str)
        @tguard = tguard
        @tmatch = tmatch

        @loc = loc
        @str = str
    end

    def inspect
        # verbose
        # "#{"PathCondition".colorize(:green)}{tguard=#{tguard.to_s.colorize(:yellow)}, tmatch=#{tmatch.to_s.colorize(:red)}, str=#{str.colorize(:grey)}}"

        # compact
        "{#{str.colorize(:grey)} => #{tmatch.to_s.colorize(:red)}}"
    end

    # to_s is just like #inspect but without the colors.
    def to_s
        # verbose
        # "#{"PathCondition"}{tguard=#{tguard.to_s}, tmatch=#{tmatch.to_s}, str=#{str}}"

        # compact
        "{#{str} => #{tmatch.to_s}}"
    end

    # RDL::Type::Path.can_index?(Path, Path) -> Bool
    # Can p1 index into p2? A.k.a. are all elements in p2 also in p1?
    # p1 and p2 are BOTH `Path`
    # The example here would be:
    # My current pi is p1. I have a variable that is <=_p2 Integer.
    # With the knowledge of p1, can I assume that variable is an Integer?
    def self.can_index?(p1, p2)
        (p2.conds - p1.conds).empty?
    end

    def clone
        PathCondition.new(@tguard.copy, @tmatch.copy, @loc, @str)
    end
    alias :copy :clone

end