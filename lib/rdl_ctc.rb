




module RDL

# Interface for Contract Objects
class Contract
    def apply(*v)
        (check *v) ? v : false #(raise "Value(s) #{v.inspect} does not match contract(s) #{self}")
    end
    def check(*v); end
    def to_s; end
    def to_proc
        x = self
        Proc.new { |v| x.check v }
    end
    def implies(&ctc)
        #TODO
    end
end

# First Order Contract
class RootCtc < Contract
    def initialize(desc="No Description", &ctc)
        @pred = ctc
        @str = desc
    end
    def check(*v)
        @pred.call unless ((@pred.arity < 0) ? @pred.arity.abs <= v.size : @pred.arity == v.size)
    end
    def to_s
        "#<RootCtc:#{@str}>"
    end
end

# Higher Order Contract Interface
class OrdNCtc < Contract
    @cond = Proc.new{}
    def initialize(desc="Blank Contract Bundle: No Description", lctc, rctc)
        init()
        @str = desc
        @lctc = lctc
        @rctc = rctc
    end
    def init; end
    def check(*v)
        @cond.call(lctc.check(*v), rctc, v)
    end
end

# Contract where both child contracts are checked
# TODO: Rename AndCtc once deprecated moved
class AandCtc < OrdNCtc
    def init
        @cond = Proc.new{|l,r,v| l && r.check(*v)}
    end
    def to_s
        "#<ANDCtc:#{@str}>"
    end
end

# Contract where one or both child contracts are checked
class OrCtc < OrdNCtc
    def init
        @cond = Proc.new{|l,r,v| }
    end
    def to_s
        "#<ORCtc:#{@str}>"
    end
end

class PreCtc < RootCtc; end

class PostCtc < RootCtc; end


############ TODO: self.convert


#################################### V DEPRECATED V #######################################

class FlatCtc < Contract
    def initialize(s = "FlatCtc:Predicate", &p)
        raise "Expected predicate, got #{p}" unless p.arity.abs == 1
        @str = s.to_s; @pred = p
    end
    def apply(v)
        (check v) ? v : (raise "Value #{v.inspect} does not match contract #{self}")
    end
    def check(v)
        @pred.call v
    end
    def to_s; "#<FlatCtc:#{@str}>" end
end

class AndCtc < Contract
    def initialize(*subs)
        @subs = subs.map { |v| RDL.convert v }
    end
    def apply(v)
        @subs.reduce(v) { |a, c| c.apply a }
    end
    def check(v)
        @subs.all? { |c| c.check v }
    end
    def to_s; "#<AndCtc:#{@subs}>" end
end

class ImpliesCtc < Contract
    def initialize(lhs, rhs)
        @lhs = RDL.convert lhs
        raise "Expected flat contract, got #{@lhs}" unless @lhs.is_a? FlatCtc
        @rhs = RDL.convert rhs
    end
    def apply(v)
        return v unless @lhs.check v
        @rhs.apply v
    end
    def check(v)
        not (@lhs.check v) or (@rhs.check v)
    end
    def to_s; "#<ImpliesCtc:#{@lhs}=>#{@rhs}>" end
end

def self.flat(&b)
FlatCtc.new &b
end

def self.convert(v)
case v
    when Contract
    v
    when Proc
    raise "Cannot convert non-unary proc #{p}" unless v.arity.abs == 1
    flat &v
    else
    FlatCtc.new(v) { |x| v === x }
end
end

def self.not(c)
c = RDL.convert c
raise "Expected flat contract, got #{c}" unless c.is_a? FlatCtc
flat { |x| not (c.check x) }
end

def self.or(*cs)
cs = cs.map { |c| RDL.convert c }
cs.each { |c| raise "Expected flat contract, got #{c}" unless c.is_a? FlatCtc}
flat { |x| cs.any? { |c| c.check x } }
end

def self.and(*cs)
AndCtc.new *cs
end

def self.implies(lhs, rhs)
ImpliesCtc.new lhs, rhs
end

#################################### ^ DEPRECATED ^ #######################################

end
