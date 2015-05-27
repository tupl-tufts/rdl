module RDL


  class Contract2
    def apply(v); end
    def check(v); end
    def to_s; end
    def to_proc
      x = self
      Proc.new { |v| x.check v }
    end
  end

  class MyCtc < Contract2
    def initialize(s = "myctc", &p)
      @str = s.to_s; @pred = p
    end

    def apply(*v)
      (check v) ? v : (raise "MyCtc Value #{v.inspect} does not match contract #{self}")
    end

    def check(*v)
      @pred.call *v
    end

    def to_s; "#<MyCtc:#{@str}>" end
  end

  class MyCtc2 < Contract2
    def initialize(s = "myctc2", &p)
      @str = s.to_s; @pred = p
    end

    def apply(v)
      (check v) ? v : (raise "MyCtc Value #{v.inspect} does not match contract #{self}")
    end

    def check(v)
      @pred.call v
    end

    def to_s; "#<MyCtc:#{@str}>" end
  end


##########################
### Contract Structure ###

class Contract
    @noerr = true
    def apply(*v)
        (check *v) ? v : errcase(v)
    end
    def errcase(v)
        @noerr ? false : (raise "Value(s) #{v.inspect} does not match contract(s) #{self}")
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
    def rdoc_gen
        "Empty Contract"
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
    alias :old_is_a? :is_a?
    def is_a?(klass)
        tmp = old_is_a?(klass)
        if (@ctc.is_a? CtcLabel) then
            return (tmp||@ctc.is_a?(klass))
        end
        tmp
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

class NamedCtc < CtcLabel
    def initialize(wctc,desc)
        super(wctc)
        @lbl = desc
    end
    def rdoc_gen
        "#{@lbl}:#{@ctc.rdoc_gen}"
    end
end

######################
### Flat Contracts ###

# Contract using user-defined block
class RootCtc < Contract
    def initialize(desc="No Description", &ctc)
        @pred = ctc
        @str = desc
        @node_bindings = [] # TODO: Add node bindings for CbD-CSP
    end
    def check(*v)
        @pred.call(*v) if ((@pred.arity < 0) ? @pred.arity.abs <= v.size : @pred.arity == v.size)
    end
    def to_s
        "#<RootCtc:#{@str}>"
    end
    def rdoc_gen
        #TODO:
        ""
    end
end

# Shortcut for creating contracts from typesigs
class TypeCtc < RootCtc
    def initialize(desc="No Description", typ)
        @str = desc
        @typeannot = typ #B: typ should be Class or some RDLClass with to_s
        #B TODO: Convert TypeAnnot typ into block and assign to @pred
    end
    def getType
        @typeannot
    end
    def getTypeS
        return @typeannot.to_s
    end
    def rdoc_gen
        return @typeannot.to_s
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
        @connect = ", "
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
    def rdoc_gen
        ret=""
        @ctcls.each {|x| ret +=x.rdoc_gen; ret +=@connect;}
        ret[0...-@connect.size]
    end
end

# Contract where all child contracts must be held
class AndCtc < OrdNCtc
    def init
        @emp=true
        @cond = Proc.new{|l,r,v| l && r.check(*v)}
        @connect = " AND "
    end
    def to_s
        "#<ANDCtc:#{@str}>"
    end
end

# Contract where any one child contract must be held
class OrCtc < OrdNCtc
    def init
        @cond = Proc.new{|l,r,v| l || r.check(*v)}
        @connect = " OR "
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
        "#{@mname}(#{@lctc.rdoc_gen}) -> @{@rctc.rdoc_gen}"
    end #TODO: RI support
end

class IntersectMCtc < MethodCtc
    def check(*v)
        tempbool = @lctc.check(*v)
    end
    
end

class BlockCtc < MethodCtc
    # Initialized with block as first arg instead of mname
    def check(*v)
        false unless @lctc.check(*v) && @rctc.check(*v,@mname.call(*v))
    end
    def rdoc_gen
        "Block{|#{@lctc.rdoc_gen}| -> #{@rctc.rdoc_gen}}"
    end
end

end
