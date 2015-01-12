




module RDL
    
    # Deprecated
    class Contract2
        def apply(v); end
        def check(v); end
        def to_s; end
        def to_proc
            x = self
            Proc.new { |v| x.check v }
        end
    end
    
    # Deprecated
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
    
    # Deprecated
    class MyCtc2 < Contract2
        def initialize(s = "myctc2", &p)
            @str = s.to_s; @pred = p
        end
        
        def apply(v)
            (check v) ? v : (raise "MyCtc Value #{v.inspect} does not match contract #{self.rdoc_gen}")
        end
        
        def check(v)
            @pred.call v
        end
        
        def to_s; "#<MyCtc:#{@str}>" end
    end
    
    ##########################
    
    
    ##########################
    ### Contract Structure ###
    
    class Contract
        def name(desc="Contract<#{self}>")
            @name = desc;
        end
        def get_name()
            @name
        end
        def apply(*v)
            begin
                check *v
            rescue
                #p "founderr #{$!}"
                return false
            end
            true
        end
        def check(*v); end
        def to_s; end
        def to_proc
            x = self
            Proc.new { |v| x.check v }
        end
        def descr(str)
            @str = str
            self
        end
        def rdoc_gen
            "Empty Contract"
        end
        def AND(ctc)
            (is_a? AndCtc) ? (add_ctc):(AndCtc.new(self,ctc))
        end
        def OR(ctc)
            (is_a? OrCtc) ? (add_ctc):(OrCtc.new(self,ctc))
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
            #puts "IS_A #{self.to_s}"
            tmp = old_is_a?(klass)
            return (tmp||@ctc.is_a?(klass))
        end
        def rdoc_gen
            "##{self.class} : #{@ctc.rdoc_gen}"
        end
    end
    
    class PreCtc < CtcLabel
    end
    
    class PostCtc < CtcLabel
    end
    
    ############################
    ### Functional Contracts ###
    
    # Contract using user-defined block
    class FlatCtc < Contract
        def initialize(desc="No Description", &ctc)
            @pred = ctc
            @str = desc
            #@str = @pred.to_source(:strip_enclosure => true)
            @node_bindings = [] # TODO: Add node bindings for CbD-CSP
        end
        def check(*v)
            #p "checksize #{v.size}:#{v} arity #{@pred.arity}"
            if (@pred && ((@pred.arity < 0) ? (@pred.arity.abs - 1) <= v.size : @pred.arity == v.size)) then
                # TODO: Labels and proc.parameters :lbl, :rest
                ret = @pred.call(*v)
                return ret ? ret : (raise "Value(s) #{v.inspect} does not match contract(s) #{self.rdoc_gen}");
            else
                #puts "Checksize failed: Given<#{v.size}> Expecting:<#{@pred.arity}>"
                raise "Error: Invalid number of arguments in Contract #{self.rdoc_gen}: Expecting arity #{@pred.arity}, got #{v}"
                return false
            end
            return true
        end
        def rdoc_gen
            "{FlatCtc:#{@str}}"
        end
    end
    
    # Deprecated
    # Contract enforcing types
    class TypeCtc < FlatCtc
        def rdoc_gen
        end
    end
    
    # Contract that applies pre(left) and post(right) condition
    class MethodCtc < FlatCtc
        def initialize(mname,lctc,rctc)
            @mname = mname
            @lctc = lctc
            @rctc = rctc
            @pred = Proc.new{|env, *v| @lctc.check(*v) && @pred_sub.call(env, *v)}
            @pred_sub = Proc.new{|env, *v| @self = env; @ret = env.send(@mname.to_sym,*v); @rctc.check(*v, @ret)}
        end
        def add_pre(ctc)
            @lctc = AndCtc.new(@lctc,ctc) # TODO eval order
        end
        def add_post(ctc)
            @rctc = AndCtc.new(@rctc,ctc)
        end
        def rdoc_gen
            x = (@lctc.class == Array) ? (@lctc.each {|t| t.rdoc_gen} ).join(',') : @lctc.rdoc_gen
            y = (@rctc.class == Array) ? (@rctc.each {|t| t.rdoc_gen} ).join(',') : @rctc.rdoc_gen
            "CONTRACT for METHOD #{@mname}\n\t(#{x})\n\t-> #{y}"
        end #TODO: RI support, rename rdoc_gen to to_s
    end
    
    class BlockCtc < MethodCtc
        # Initialized with block as first arg instead of mname
        # TODO
        def rdoc_gen
            x = ""
            y = ""
            "Block{|#{x}| -> #{y}}"
        end
    end
    
    ############################
    ### Combinator Contracts ###
    
    # Inner-node structure for contracts capable of holding multiple child contracts
    class OrdNCtc < Contract
        @cond = Proc.new{}
        def initialize(*ctcs)
            @ctcls = ctcs
            @emp = false
            @connect = ", "
            init()
        end
        def init; end
        def check(*v)
            ret = check_aux(v,0)
            ret ? ret : (raise "Contract #{self.class}<#{get_name}> not fulfilled")
        end
        def check_aux(v, nt)
            #puts "check aux begin from v: #{v} and nt: #{nt}"
            ret = (nt >= @ctcls.length) ? @emp : @cond.call(@ctcls[nt], v, nt)
            #puts "check aux return: #{ret} from v: #{v} and nt: #{nt}"
            ret
        end
        def add_ctc(ctc)
            (ctc.is_a? Contract) ? (@ctcls<<ctc):(raise "Attempting to add non-Contract to Contract bundle")
        end
        def rdoc_gen
            rdc=""
            @ctcls.each {|x| rdc +=x.rdoc_gen; rdc +=@connect;}
            rdc[0...-@connect.size]
        end
    end
    
    # Contract where all child contracts must be held
    class AndCtc < OrdNCtc
        def init
            @emp=true
            @cond = Proc.new{|l, v, nt| l.check(*v) && check_aux(v, nt+1)}
            @connect = " AND "
        end
    end
    
    # Contract where any one child contract must be held
    class OrCtc < OrdNCtc
        def init
            @cond = Proc.new{|l, v, nt| l.apply(*v) || check_aux(v, nt+1)}
            @connect = " OR "
        end
    end
    
end
