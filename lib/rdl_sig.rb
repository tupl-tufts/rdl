module RDL
  class << self
    attr_accessor :bp_stack
  end

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
    
    def typesig(sig, meta={})
      mname = @mname.to_sym
      parser = RDL::Type::Parser.new
      type = parser.scan_str(sig)
      tvars = meta[:vars].nil? ? [] : meta[:vars]

      cls_typesigs = @class.instance_variable_get :@__typesigs
      cls_param_symbols = @class.instance_variable_get(:@__cls_params).keys
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
        raise RDL::InvalidParameterException, "Invalid parameters #{invalid_tparams.inspect} in #{@class}##{@mname} typesig #{sig}"
      end
      
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

      arg_chosen_type = nil
      ret_chosen_type = nil
      method_types = cls_typesigs[mname]
      status = nil
      method_blk = nil
      RDL.bp_stack = [] if not RDL.bp_stack

      c = Proc.new {|args| 
        if method_blk
          arg_chosen_type = RDL::MethodCheck.select_and_check_args(method_types, mname, args, true)
        else
          arg_chosen_type = RDL::MethodCheck.select_and_check_args(method_types, mname, args)
        end

        arg_chosen_type
      }

      bp = nil

      c2 = Proc.new {|ret|
        ret_chosen_type = nil

        bp = RDL.bp_stack[-1]

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

        ret_chosen_type = arg_chosen_type if not ret_chosen_type
        ret_valid = RDL::MethodCheck.check_return(ret_chosen_type, ret)
        ret_valid
      }

      ctc = MyCtc.new(&c)
      ctc_r = MyCtc2.new("regular_ret #{mname}", &c2)
      status = nil

      arg_check_name = define_method_gensym("check_args") do |*args, &blk|
        args = ctc.apply(*args)


        if blk
          bp = BlockProxy.new(blk, arg_chosen_type.block, self.class, mname)
          blk = BlockProxy.wrap_block bp
          RDL.bp_stack.push bp
        end

        { args: args, block: blk }
      end

      no_arg_check_name = define_method_gensym("check_args") do |*args, &blk|
       { args: args, block: blk }
      end

      ret_check_name = define_method_gensym("check_ret") do |ret, *args, &blk|
        r = ctc_r.apply(ret)
        RDL.bp_stack.pop
        r
      end

      no_ret_check_name = define_method_gensym("check_ret") do |ret, *args, &blk|
        ret
      end

      pre do |*args, &blk|
        status = RDL.on?
        
        if status
          begin
            RDL.turn_off
            tp = self.instance_variable_get :@__rdl_s_type_parameters
            tp = {} if not tp
            uninstantiated_params = cls_param_symbols - tp.keys
            uninstantiated_params.each {|up| tp[up] = RDL::Type::TopType.new}
            method_types = cls_typesigs[mname]
            method_types = method_types.replace_vartypes tp
            method_blk = blk
            
            r = self.__send__ arg_check_name, *args, &blk
          ensure
            RDL.turn_on
          end
          r
        else
          self.__send__ no_arg_check_name, *args, &blk
        end
      end
        
      post do |ret, *args, &blk|
        status = RDL.on?
        if status
          begin
            RDL.turn_off
            r = self.__send__ ret_check_name, ret, *args, &blk
          ensure
            RDL.turn_on
          end
          
          r
        else
          self.__send__ no_ret_check_name, ret, *args, &blk
        end
      end
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
            
            #B: following code may be useful
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
            
            tsig = MethodCtc.new(@mname,self,prmctc,retctc)
            #B: end of useful code chunk
            
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

module RDL
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
end
