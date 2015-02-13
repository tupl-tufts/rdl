module RDL
    
class << self
    attr_accessor :bp_stack
end

# Wrapper for method
class Spec
    attr_accessor :klass, :mname, :contract
    
    def initialize(cls, mname)
        @klass = cls
        @mname = mname
        
        # Initialize ctc_list (List of Method Contracts)
        store_get_contract()
        
        # TODO: Fix typesig before method definition feature
        unless cls.method_defined? mname or mname.to_sym == :initialize
            raise "Method #{mname} not defined for #{cls}"
        end
    end
    
    # Stores and/or Retrieves typesig contract
    def store_get_contract()
        
        # Create or append Method Contract
        mname_old = @mname.to_s + "_old"
        mname_old = mname_old[0]=="\"" ? mname_old : "\"#{mname_old}\"".to_sym
        
        if @contract.nil? then
            wrap_method()
            @contract = MethodCtc.new(mname_old, FlatCtc.new("StudT") {|*v| true}, FlatCtc.new("StudT") {|*v| true})
        end
        
        return @contract
    end
    
    # Shortcut Methods for appending Preconditions and Postconditions
    def pre_cond(desc = "User Precondition", ctc=nil &blk)
        RDL.debug "pre_cond_called", 8
        store_get_contract().add_pre (ctc && ctc.is_a?(Contract) ? ctc : PreCtc.new FlatCtc.new(desc, &blk))
    end
    
    def post_cond(desc = "User Postcondition", &blk)
        RDL.debug "post_cond_called", 8
        store_get_contract().add_post (ctc && ctc.is_a?(Contract) ? ctc : PostCtc.new FlatCtc.new(desc, &blk))
    end
    
    # Wraps a method with type contracts
    # @params String:sig ?Hash:meta *Contract:ctcls
    def typesig(sig, *metactc)
        mname = @mname.to_sym
        
        if(metactc[0].is_a? Hash)then
            meta = metactc[0]
            ctcls = metactc[1..-1]
        else
            meta = {}
            ctcls = metactc
        end
        
        # Scan typesig annotation into MethodType<:arg_type, :ret_type, :block_type>
        parser = RDL::Type::Parser.new
        type = parser.scan_str(sig)
        
        # Parameterized type handler
        tvars = meta[:vars].nil? ? [] : meta[:vars]
        
        cls_typesigs = @klass.instance_variable_get :@__typesigs
        
        cls_param_symbols = @klass.instance_variable_get(:@__cls_params).keys # gets the :t in Array
        valid_param_symbols = tvars + cls_param_symbols
        
        common_tparams = tvars & cls_param_symbols
        if not common_tparams.empty?
            raise RDL::InvalidParameterException, "Parameters #{common_tparams} are used both as class type_param and method type_param"
        end
        
        valid_tparams = tvars + cls_param_symbols
        invalid_tparams = []
        
        type.get_vartypes.each {|p|
            invalid_tparams.push(p) if not valid_param_symbols.include?(p)
        }
        if not invalid_tparams.empty?
            raise RDL::InvalidParameterException, "Invalid parameters #{invalid_tparams.inspect} in #{@klass}##{@mname} typesig #{sig}"
        end
        
        # Intersection type handler
        if cls_typesigs.keys.include?(mname)
            extant_type = cls_typesigs[mname]
            
            if extant_type.instance_of? RDL::Type::IntersectionType
                type = [type] + extant_type.types.to_a
            else
                type = [type, extant_type]
            end
            
            cls_typesigs[mname] = RDL::Type::IntersectionType.new(*type)
        else
            cls_typesigs[mname] = type
        end
        
        # Typesig Check Contracts
        
        # Class Vars
        arg_chosen_type = nil
        method_types = cls_typesigs[mname]
        method_blk = nil
        #RDL.bp_stack = [] if not RDL.bp_stack
        
        # Handle unusual types
        ret_chosen_type = nil
        bp = nil #RDL.bp_stack[-1]
        
        # Preconditions
        mcheck_pre = FlatCtc.new "Typesig Precondition", &Proc.new{ |*args| #TODO &blk?
            
            RDL.debug "PRE called", 3
            
            # Recursion Security

#status = RDL.on?
#            p status
#            if status
                begin
                    #                    RDL.turn_off
                    tp = self.instance_variable_get :@__rdl_s_type_parameters
                    tp = {} if not tp
                    uninstantiated_params = cls_param_symbols - tp.keys
                    uninstantiated_params.each {|up| tp[up] = RDL::Type::TopType.new}
                    method_types = cls_typesigs[mname]
                    method_types = method_types.replace_vartypes tp
                    #method_blk = blk
                
                    # Select between Intersection Types then Check
                    if method_blk
                        arg_chosen_type = RDL::MethodCheck.select_and_check_args(method_types, mname, args, true)
                    else
                        arg_chosen_type = RDL::MethodCheck.select_and_check_args(method_types, mname, args)
                    end
            
                    RDL.debug "PRE arg_chosen_type #{arg_chosen_type}", 3
            
                ensure
                #    RDL.turn_on
                end
                #end
            
            next true # Passes pre-check if there exists a valid method type for input params or if no checks are necessary
            
        }
        
        # Postconditions
        mcheck_post = FlatCtc.new "Typesig Postcondition", &Proc.new{ |*args,ret|
            
            RDL.debug "POST called", 3
            
            # Handle checking and return
            #status = RDL.on?
            #if status
                begin
            #        RDL.turn_off
                    
                    # TODO: Add bp
                    if bp
                        vm = bp.var_map
                        vm2 = {}
                        if not vm.empty?
                            vm.each {|vmk, vmv|
                                uv = RDL::TypeInferencer.unify_param_types vmv
                                vm2[vmk] =  RDL::Type::UnionType.new(*uv)
                            }
                            ret_chosen_type = arg_chosen_type.replace_vartypes vm2
                        end
                    end
                    
                    RDL.debug "POST arg_chosen_type #{arg_chosen_type}\nPOST ret_chosen_type #{ret_chosen_type}", 3
                    
                    ret_chosen_type = arg_chosen_type if not ret_chosen_type
                    ret_valid = RDL::MethodCheck.check_return(ret_chosen_type, ret)
                    
                    RDL.debug "POST ret_chosen_type_final #{ret_chosen_type}", 3
                    
                    next ret_valid
                ensure
                # RDL.turn_on
                end
                #  else
                #next true # Does not finish check or guarantee anything if RDL is currently off
                #end
            
        }
        
        RDL.debug "PRE POST created? #{mcheck_pre.rdoc_gen} :: #{mcheck_post.rdoc_gen}", 3
        
        # Append user pre/post-conditions
        ctcls.each {|ctc|
            
            if(ctc.is_a? PreCtc) then
                mcheck_pre = mcheck_pre.AND(ctc)
            elsif(ctc.is_a? PostCtc) then
                mcheck_post = mcheck_post.AND(ctc)
            end
            
        }
        
        ctc = store_get_contract()
        ctc.add_pre mcheck_pre
        ctc.add_post mcheck_post
        
        RDL.debug ctc.rdoc_gen, 1
        
        # TODO NamedType
        named = []
                
    end
    
    # Patches method :@mname to check when called
    def wrap_method()
        
        args_val = []
        ret_val = nil
        
        mname = @mname
        mname_old = (mname.to_s + "_old").to_sym
        mname_old = mname_old[0]=="\"" ? mname_old : "\"#{mname_old}\"".to_sym
        
        # TODO Corner case error: "[]_old".to_sym == :"[]_old" instead of :[]_old
        
        
        kls = @klass
        
        # Only need to wrap once
        if kls.instance_methods.include?(mname_old) then
            return
        end
        
        kls.class_eval do
            alias_method mname_old, mname
            define_method mname do |*v|
                if RDL.on?
                    mctc = kls.instance_variable_get(:@__rdlcontracts)[mname].contract
                    return mctc.ret if mctc.check(self,*v).nil? #TODO: attr_accessor for :@ret, contract return pair <TF, ret>
                end
                
                return send(mname_old, *v)

            end
            def args
                args_val
            end
            def ret
                ret_val
            end
        end
    
    end

end # End of class RDL::Spec

end # End of Module RDL


class Object
    
    # Typesig method wrapping in the case of not yet defined methods
    def self.method_added(mname)
        specs = self.instance_variable_get :@__deferred_specs
        typesigs = self.instance_variable_get :@__deferred_typesigs
    
        if specs and specs.keys.include? mname
            spec &(specs[mname])
            specs.delete mname
            RDL.debug "Deferred typesig #{mname} created", 1
        end

        if typesigs and typesigs.include? mname
            typesig(*(typesigs[mname]))
            typesigs.delete mname
            RDL.debug "Deferred typesig #{mname} created", 1
        end

    end

end
