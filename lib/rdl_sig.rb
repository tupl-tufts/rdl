


module RDL

class Spec
    def initialize(cls, mname)
        @class = cls
        @mname = mname
        
        # TODO: Fix typesig before method definition feature
        unless cls.method_defined? mname or mname.to_sym == :initialize
            raise "Method #{mname} not defined for #{cls}"
        end
    end
    
    def include_spec(blk, *args)
        unless blk.is_a?(Proc)
            raise "Expected a Proc, got #{blk.inspect}"
        end
        instance_exec(*args, &blk)
    end
    
    # Takes a block that transforms the incoming arguments
    # into (possibly) new arguments to be fed to the method.
    def pre(&b)
        mname = @mname
        old_mname = "__dsl_old_#{mname}_#{gensym}"
        pre_name = define_method_gensym("pre", &b)
        
        @class.class_eval do
            alias_method old_mname, mname
            
            define_method mname do |*args, &blk|
                results = self.__send__ pre_name, *args, &blk
                new_args = results[:args]
                new_blk = results[:block]
                self.__send__ old_mname, *new_args, &new_blk
            end
        end
    end
    
    # Takes a block that transforms the return value
    # into a (possibly) return value to be returned from the method.
    # The block also gets handed the original arguments.
    def post(&b)
        mname = @mname
        old_mname = "__dsl_old_#{mname}_#{gensym}"
        post_name = define_method_gensym("post", &b)
        
        @class.class_eval do
            alias_method old_mname, mname
            
            define_method mname do |*args, &blk|
                res = self.__send__ old_mname, *args, &blk
                self.__send__ post_name, res, *args, &blk
            end
        end
    end
    
    def store_method_type(sig_type)
        n = RDL::Type::NominalType.new @class
        n.add_method_type(@mname, sig_type)
    end
    
    # DEPRECATED: Use typesig instead
    def typesig_c(sig)
        parser = RDL::Type::Parser.new
        t = parser.scan_str(sig)
        
        store_method_type(t)
        
        c_args = []
        
        t.args.each {|ta|
            ca_str = "RDL.flat {|a| a.rdl_type <= ta}"
            ca = eval(ca_str)
            c_args.push(ca)
        }
        
        ctcs = c_args.map {|x| RDL.convert x}
        
        arg_check_name = define_method_gensym("check_arg") do |*args, &blk|
            for i in 0..t.args.size-1
                args[i] = ctcs[i].apply(args[i])
            end
            
            if blk
                bp = BlockProxy_c.new(blk, t.block)
                blk = BlockProxy_c.wrap_block(bp)
            end
            
            { args: args, block: blk }
        end
        
        annotated_ret = t.ret
        cr_str = "RDL.flat {|r| r.rdl_type <= annotated_ret}"
        cr = eval(cr_str)
        ctc_r = RDL.convert cr
        
        arg_check_name_post = define_method_gensym("check_arg_post") do |ret, *args, &blk|
            ret = ctc_r.apply(ret)
            
            ret
        end
        
        pre do |*args, &blk|
            self.__send__ arg_check_name, *args, &blk
        end
        
        post do |ret, *args, &blk|
            self.__send__ arg_check_name_post, ret, *args, &blk
        end
    end
    
    def typesig(sig, meta={})
        status = @@master_switch
        @@master_switch = false if status
        
        begin
            parser = RDL::Type::Parser.new
            t = parser.scan_str(sig)
            tvars = meta[:vars].nil? ? [] : meta[:vars]
            cls_params = RDL::Type::NominalType.new(@class).type_parameters
            cls_param_symbols = cls_params.map {|p| p.symbol}
            valid_param_symbols = tvars + cls_param_symbols
            
            invalid_tparams = []
            
            t.get_method_parameters.each {|p|
                invalid_tparams.push(p) if not valid_param_symbols.include?(p)
            }
            
            if not invalid_tparams.empty?
                raise RDL::InvalidParameterException, "Invalid parameters #{invalid_tparams.inspect} in #{@class}##{@mname} typesig #{sig}"
            end
            
            if tvars
                tvars = tvars.map {|x| RDL::Type::TypeParameter.new(x.to_sym)}
                t.parameters = tvars
            end
            
            n = RDL::Type::NominalType.new @class
            t_old = n.get_method(@mname)
            store_method_type(t)  # may make an intersection type
            t = n.get_method(@mname)
            
            mname = @mname
            old_mname = "__dsl_old_#{mname}"
            
            ti = @class.instance_variable_get(:@typesig_info)
            ti[mname] = [@class, mname, old_mname, cls_param_symbols, t]
            
            if t_old
                @class.class_eval do
                    alias_method mname, old_mname
                end
            end
            
            ensure
            @@master_switch = true if status
        end
        RDL::MethodWrapper.wrap_method(@class, mname, old_mname, cls_param_symbols, t)
    end
    
    # Proposed changes to typesig
    def typesig_neo(sig, *ctcmeta)
        meta = ((ctcmeta[0].is_a? Hash) ? ctcmeta[0]:{})
        status = @@master_switch
        @@master_switch = false if status
        
        begin
            # Extracting type information from typesig annotation as NominalType
            parser = RDL::Type::Parser.new
            t = parser.scan_str(sig)
            tvars = meta[:vars].nil? ? [] : meta[:vars]
            
            # Handling type params
            cls_params = RDL::Type::NominalType.new(@class).type_parameters
            cls_param_symbols = cls_params.map {|p| p.symbol}
            valid_param_symbols = tvars + cls_param_symbols
            invalid_tparams = []
            t.get_method_parameters.each {|p|
                invalid_tparams.push(p) if not valid_param_symbols.include?(p)
            }
            if not invalid_tparams.empty?
                raise RDL::InvalidParameterException, "Invalid parameters #{invalid_tparams.inspect} in #{@class}##{@mname} typesig #{sig}"
            end
            if tvars
                tvars = tvars.map {|x| RDL::Type::TypeParameter.new(x.to_sym)}
                t.parameters = tvars
            end
            
            # TODO: Or Contracts and Optional Vars, Etc
            # Handling pre conditions and input types
            ctcmeta.each{|typ|
                if typ.is_a? Contract
                    prmctc = ((prmctc && (typ.is_a? PreCtc)) ? AandCtc.new("User Precondition",typ, prmctc):typ)
                    retctc = ((retctc && (typ.is_a? PostCtc)) ? AandCtc.new("User Postcondition",typ, prmctc):typ)
                else
                    unless (typ.is_a? Hash)
                        raise RDL::InvalidParameterException, "Invalid input to typesig. Expecting Contract received #{typ.class}!"
                    end
                end
            }
            t.method_types.each{|typ|
                if prmctc
                    prmctc = AandCtc.new("Input Parameters",typeToCtc(typ), prmctc)
                else
                    prmctc = TypeCtc.new("Type",typ)
                end
            }
            
            #TODO: Return Type
            
            #TODO: Store method
            
            #TODO: Store original value, instance eval or read labelled types
            
            # Wrapping Method to execute typesig check
            mname = @mname
            old_mname = "__dsl_old_#{mname}"
            ti = @class.instance_variable_get(:@typesig_info)
            ti[mname] = [@class, mname, old_mname, cls_param_symbols, t] #TODO: Put MethodCtc Here
            
            unless @class.instance_methods(false).include?(mname)
                #TODO: Alias method_added to call gen_method_wrap
            else
                gen_method_wrap
            end
            
            ensure
            @@master_switch = true if status
            
        end
    end
    
    def gen_method_wrap(mname)
        tempstr = "
        def #{mname.to_s} (*args)
            return @class.instance_variable_get(:@typesig_info)[-1].check(*v)
        end
        "
        @class.class_eval do
            alias_method mname, old_mname
        end
        @class.class_eval(tempstr)
    end

    
    # Checks argument n (positional) against contract c.
    def arg(n, c)
        ctc = RDL.convert c
        arg_name = define_method_gensym("arg") do |*args, &blk|
            raise "#{n+1} arguments expected, got #{args.length}" if args.length <= n
            args[n] = ctc.apply(args[n])
            { args: args, block: blk }
        end
        
        pre do |*args, &blk|
            self.__send__ arg_name, *args, &blk
        end
    end
    
    # Checks optional argument n (positional) against contract c, if given.
    def opt(n, c)
        ctc = RDL.convert c
        arg_name = define_method_gensym("arg") do |*args, &blk|
            args[n] = ctc.apply(args[n]) if args.length > n
            { args: args, block: blk }
        end
        
        pre do |*args, &blk|
            self.__send__ arg_name, *args, &blk
        end
    end
    
    # Checks rest args after first n args (positional) against contract c.
    def rest(n, c)
        ctc = RDL.convert c
        arg_name = define_method_gensym("rest") do |*args, &blk|
            raise "At least #{n} arguments expected, got #{args.length}" if args.length < n
            args[n..-1] = args[n..-1].map { |i| ctc.apply i }
            { args: args, block: blk }
        end
        
        pre do |*args, &blk|
            self.__send__ arg_name, *args, &blk
        end
    end
    
    # Checks return value against contract c.
    def ret(c)
        ctc = RDL.convert c
        ret_name = define_method_gensym("ret") do |r, *args, &blk|
            ctc.apply(r)
        end
        
        post do |r, *args, &blk|
            self.__send__ ret_name, r, *args, &blk
        end
    end
    
    # Checks return value against contract generated by applying arguments
    # to block argument
    def ret_dep(&b)
        ret_dep_ctc_name = define_method_gensym("ret_dep_ctc", &b)
        ret_dep_name = define_method_gensym("ret_dep") do |r, *args, &blk|
            ctc = RDL.convert(self.__send__ ret_dep_ctc_name, *args)
            ctc.apply(r)
        end
        
        post do |r, *args, &blk|
            self.__send__ ret_dep_name, r, *args, &blk
        end
    end
    
    # pre/post_task are versions of pre/post that ignore the
    # return value from the block and just pass along the
    # original arguments or return value.
    
    def pre_task(&b)
        pre_task_name = define_method_gensym("pre_task", &b)
        
        pre do |*args, &blk|
            self.__send__ pre_task_name, *args, &blk
            { args: args, block: blk }
        end
    end
    
    def post_task(&b)
        post_task_name = define_method_gensym("post_task", &b)
        
        post do |r, *args, &blk|
            self.__send__ post_task_name, r, *args, &blk
            r
        end
    end
    
    class PreConditionFailure < Exception; end
    class PostConditionFailure < Exception; end
    
    # pre/post_cond are like pre/post_task, except they check
    # the block return and error if the block returns false/nil.
    
    def pre_cond(desc = "", &b)
        pre_cond_name = define_method_gensym("pre_cond", &b)
        
        pre_task do |*args, &blk|
            raise PreConditionFailure, desc unless send pre_cond_name, *args, &blk
        end
    end
    
    def post_cond(desc = "", &b)
        post_cond_name = define_method_gensym("post_cond", &b)
        
        post_task do |r, *args, &blk|
            raise PostConditionFailure, desc unless send post_cond_name, r, *args, &blk
        end
    end
    
    # Since we're describing an existing method, not creating a new DSL,
    # here we want the dsl keyword to just intercept the block and add
    # our checks. We'll overwrite this functionality inside the entry version.
    def dsl(*a, &b)
        spec = Dsl.new *a, &b
        dsl_from spec
    end
    
    def dsl_from(spec, flags = {})
        p = Proxy.new flags[:warn]
        spec.specs.each_pair { |m, b| p.add_method m }
        spec.apply(p.instance_variable_get(:@class))
        pre do |*args, &blk|
            # Allow for methods that only sometimes take DSL blocks.
            if blk
                new_blk = Proc.new do |*args|
                    unless self.is_a? RDL::Proxy
                        obj = p.apply(self)
                        else
                        spec.specs.each_pair { |m, b| add_method m }
                        spec.apply(class << self; self; end)
                        obj = self
                    end
                    obj.instance_exec(*args, &blk)
                end
                { args: args, block: new_blk }
                else { args: args, block: blk }
            end
        end
    end
    
    private
    
    def define_method_gensym(desc="blk",&blk)
        blk_name = "__dsl_#{desc}_#{@mname}_#{gensym}"
        
        @class.class_eval do
            define_method blk_name, &blk
        end
        
        blk_name
    end
    
    def gensym
        RDL::Gensym.gensym
    end
end



end