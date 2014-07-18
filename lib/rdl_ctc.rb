




module RDL

class Contract
    def apply(v); end
    def check(v); end
    def to_s; end
    def to_proc
        x = self
        Proc.new { |v| x.check v }
    end
end

class FlatCtc < Contract
    def initialize(s = "predicate", &p)
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

end
