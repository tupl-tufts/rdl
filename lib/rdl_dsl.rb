



module RDL

class Dsl
    attr_accessor :keywords, :specs
    
    def initialize(*a, &blk)
        instance_eval(*a, &blk) if block_given?
    end
    
    # Define reserved word in DSL
    def keyword(mname, &blk)
        @keywords ||= {}
        raise "Keyword definition already exists for #{mname}" if @keywords[mname]
        @keywords[mname] = blk
    end
    
    # Define RDL::Spec
    def spec(mname, &blk)
        @specs ||= {}
        @specs[mname] ||= []
        @specs[mname].push(blk)
    end
    
    # Reference other RDL::Spec
    def self.extend(spec, &blk)
        raise "Expected a DSL spec, got #{spec}" unless spec.is_a?(Dsl)
        new_spec = Dsl.new
        old_keywords = spec.keywords
        if old_keywords
            new_spec.instance_variable_set(:@keywords, old_keywords.clone)
        end
        old_specs = spec.specs
        # FIXME: Probably need to do one more level down of cloning
        new_spec.instance_variable_set(:@specs, old_specs.clone) if old_specs
        new_spec.instance_eval(&blk) if block_given?
        new_spec
    end

    # TODO: describe
    def apply(cls)
        if @keywords
            @keywords.each_pair do |m, b|
                if cls.method_defined? m
                    raise "Method #{m} listed in spec already defined in #{cls}"
                end
                Keyword.new(cls, m).instance_eval(&b)
            end
        end
        if @specs
            @specs.each_pair do |m, bl|
                bl.each do |b|
                    unless cls.method_defined? m
                        raise "Method #{m} listed in spec not defined in #{cls}"
                    end
                    Spec.new(cls, m).instance_eval(&b)
                end
            end
        end
    end

end


class Keyword < Spec
    
    def initialize(cls, mname)
        if cls.method_defined? mname
            raise "Method #{mname} already defined for #{cls}"
        end
        
        @class = cls
        @mname = mname
        
        action { |*args| nil }
    end
    
    # For non-DSL keywords
    def action(&blk)
        mname = @mname
        
        @class.class_eval do
            define_method mname, &blk
        end
    end
    
    # For keywords that take the same DSL they are in
    def dsl_rec
        action do |*args, &blk|
            instance_exec(*args, &blk)
            self
        end
    end
    
    # For keywords that take a different DSL than they are in
    def dsl(cls = nil, *a, &b)
        mname = @mname
        
        raise "Need a class or block" unless cls or b
        
        unless b.nil?
            cls = Class.new(BasicObject) if cls.nil?
            cls.class_eval do include Kernel end
            Lang.new(cls).instance_exec(*a, &b)
        end
        
        action do |*args, &blk|
            c = cls.new(*a)
            c.instance_exec(*args, &blk)
            c
        end
    end
end

# DSLang Class
class Lang
    
    def initialize(cls)
        @class = cls
    end
    
    # Creates keyword
    def keyword(mname, *args, &blk)
        Keyword.new(@class, mname).instance_exec(*args, &blk)
    end
    
    # Enables contract verification
    def spec(mname, *args, &blk)
        Spec.new(@class, mname).instance_exec(*args, &blk)
    end
    
end

#V#V#V#V#V#V#V#V#V#V#V# TO DELETE #V#V#V#V#V#V#V#V#V#V#V#V#V#V#V#V#V#V#V


# TODO: Purpose of class?
class Proxy
    
    def initialize(warn = false)
        @class = Class.new(BasicObject) do
            include Kernel
            
            attr_reader :obj
            
            def initialize(obj)
                @obj = obj
            end
        end
    
        if warn
            @class.class_eval do
                def method_missing(mname, *args, &blk)
                    $stderr.puts "Attempt to call method #{mname} not in DSL at"
                    caller.each { |s| $stderr.puts "  #{s}"}
                    @obj.__send__ mname, *args, &blk
                end
            end
        else
            @class.class_eval do
                def method_missing(mname, *args, &blk)
                    raise "Attempt to call method #{mname} not in DSL"
                end
            end
        end
    end

    # TODO: desc
    def apply(obj)
        @methods.each do |m|
            unless obj.respond_to? m
                raise "Method #{m} not found in DSL object #{obj}"
            end
        end
        @class.new(obj)
    end

    # TODO: desc
    def add_method(mname)
        @methods ||= []
        @methods.push(mname)
        @class.class_eval do
            define_method mname do |*args, &blk|
                @obj.__send__ mname, *args, &blk
            end
        end
    end

end

# TODO: desc
class BlockProxy < Spec
    attr_reader :blk
    attr_reader :blk_type
    attr_reader :mname
    attr_reader :class
        attr_reader :var_map
        
        def initialize(blk, blk_type, cls, method_name)
            @blk = blk
            @blk_type = blk_type
            @class = cls
            @mname = method_name
            @var_map = {}
        end
        
        def call(*args)
            chosen_type = nil
            ret_var_map = {}
            
            c = Proc.new {|args|
                chosen_type = RDL::MethodCheck.select_and_check_args(@blk_type, @method_name, args)
                chosen_type
            }
            
            c2 = Proc.new {|ret|
                ret.rdl_type.le(chosen_type.ret, ret_var_map)
            }
            
            ctc = MyCtc.new(&c)
            ctc_r = MyCtc2.new(&c2)
            
            ctc.apply *args
            
            ret = @blk.call *args
            ctc_r.apply ret
            
            ret_var_map.each {|k, v|
                if @var_map.keys.include? k
                    @var_map[k] = @var_map[k].add v
                    else
                    @var_map[k] = Set.new v
                end
            }
            
            ret
        end
        
        def self.wrap_block(x)
        Proc.new {|*v| x.call(*v)}
    end
    
end

# TODO: Purpose of class?
class Range
    
    alias :old_initialize :initialize
    
    def initialize(*args)
        old_initialize(*args)
    end
    
    # TODO: desc and verify
    def no_iter
        []
    end
    
    # TODO: desc
    def step_iter(step_num)
        self.step(step_num)
    end
    
    # TODO: desc
    def random_iter(iter = (self.max - self.min) / 2)
        rand_set = Set.new
        prng = Random.new
        
        while rand_set.size < iter
            rand_set.add(prng.rand(self.min..self.max))
        end
        
        rand_set.to_a
    end
    
end

#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#^#

end # End of module RDL