




module RDL

##########################
### Contract Structure ###

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
    def getCtcInfo
        #TODO Returns inner data for rdoc use; in format where code can recognize contract logic
    end
end

##########################
### Contract Labelling ###

# Wrapper for Contracts
class CtcLabel < Contract
    @ctc = nil
    def initialize(wctc)
        @ctc = wctc
    end
    def apply(*v)
        @ctc.apply(*v)
    end
    def check(*v)
        @ctc.check(*v)
    end
    def to_proc
        @ctc.to_proc
    end
    def implies(&ctc)
        @ctc.implies(&ctc)
    end
end

class PreCtc < CtcLabel
    def to_s
        "#Pre-Condition : {@ctc.to_s}"
    end
end

class PostCtc < CtcLabel
    def to_s
        "#Post-Condition : #{@ctc.to_s}"
    end
end

######################
### Flat Contracts ###

# Contract using user-defined block
class RootCtc < Contract
    def initialize(desc="No Description", &ctc)
        @pred = ctc
        @str = desc
        @bindings = [] # TODO: Add node bindings for CbD-CSP
    end
    def check(*v)
        @pred.call(*v) unless ((@pred.arity < 0) ? @pred.arity.abs <= v.size : @pred.arity == v.size)
    end
    def to_s
        "#<RootCtc:#{@str}>"
    end
end

# Shortcut for creating contracts from typesigs
class TypeCtc < RootCtc
    def initialize(desc="No Description", typ)
        @str = desc
        @typeannot = typ
        # TODO: Convert TypeAnnot typ into block and assign to @pred
    end
end

##############################
### Higher Order Contracts ###

# Inner-node structure for contracts capable of holding multiple child contracts
class OrdNCtc < Contract
    @cond = Proc.new{}
    def initialize(desc="Blank Contract Bundle: No Description", *ctcs)
        @str = desc
        @ctcls = ctcs
        @emp = false
        init()
    end
    def init; end
    def check(*v)
        check_aux(v,0)
    end
    def check_aux(v, nt)
        tmp = (nt>=@ctcls.length ? @emp : check(*v,nt+1))
        @cond.call(tmp,@ctcls[nt],v)
    end
end

# Contract where all child contracts must be held
# TODO: Rename AndCtc once deprecated moved
class AandCtc < OrdNCtc
    def init
        @emp=true
        @cond = Proc.new{|l,r,v| l && r.check(*v)}
    end
    def to_s
        "#<ANDCtc:#{@str}>"
    end
end

# Contract where any one child contract must be held
class OrCtc < OrdNCtc
    def init
        @cond = Proc.new{|l,r,v| l || r.check(*v)}
    end
    def to_s
        "#<ORCtc:#{@str}>"
    end
end

# Contract that applies pre(left) and post(right) condition
class MethodCtc < OrdNCtc
    def initialize(mname,env,lctc,rctc)
        @mname = mname
        @env = env.clone
        @lctc = lctc
        @rctc = rctc
    end
    def check(*v)
        false unless @lctc.check(*v) && @rctc.check(*v,@env.send(@mname.to_sym,*v))
    end
    def to_s
        "#<TypesigMethodCtc:#{@str}>"
    end
    def rdoc_gen
        pg = RDoc::AnyMethod.new("",@mname)
        ctx = RDoc::Context.new
        # TODO: Implementation
        ctx.add_method(pg)
        
    end #TODO: RI support
end

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
