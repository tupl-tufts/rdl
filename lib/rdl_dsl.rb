



module RDL

class Dsl
    attr_accessor :keywords
    
    # Creates dsl and executes block using dsl
    def initialize(*a, &blk)
        @keywords ||= {}
        @keywords[:keyword] = 0 # Prevent :keyword from being overwritten
        apply(*a, &blk)
    end
    
    # Syntactic sugar for creating new DSLs
    def dsl(*a, &blk)
        DSL.new(*a, &blk)
    end
    
    # Define reserved word in DSL
    def keyword(mname, &blk)
        raise "Keyword definition already exists for #{mname}" if @keywords[mname]
        instance_exec do
            define_method mname do |*args|
                @keywords[mname].call(*args)
            end
        end
        @keywords[mname] = blk
    end
    
    # Import other DSL keywords
    def self.extend(other, &blk)
        raise "Expected a DSL spec, got #{spec}" unless other.is_a?(Dsl)
        otherkeys = other.keywords
        otherkeys.keys.each { |key|
            keyword(key, otherkeys[key]) unless self.keywords.include?(key)
        }
        apply(&blk)
    end

    # Executes block using dsl
    def apply(*a, &blk)
        instance_exec(*a, &blk) if block_given?
    end

end


#V#V#V#V#V#V#V#V#V#V#V# TO CHANGE / REMOVE #V#V#V#V#V#V#V#V#V#V#V#V#V#V#V#V#V#V#V

# TODO: transform this into BlockCtc
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