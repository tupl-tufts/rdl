module RDL::Type
  class VarType < Type
    attr_reader :name, :cls, :meth, :category, :to_infer, :path_sensitive
    attr_accessor :lbounds, :ubounds, :solution_source, :solution

    # All of the information needed to re-run this comp type at any time.
    # This is utilized when a method is defined with a comp type with
    # `suspend: true`. In this case, the comp type can be re-run at
    # a later step of inference (constraint resolution/solution extraction)
    # when more info about its parameters is discovered.
    # When `comp_type_info` is present, @category = :comp_type_output
    # Hash<{comp_type_meth: MethodType, comp_type_tactuals: Type[], self_klass: Class, trecv: Type}>
    attr_reader :comp_type_info

    @@cache = {}
    @@print_XXX = false

    class << self
      alias :__new__ :new
    end

    def self.new(name_or_hash)
      if name_or_hash.is_a?(Symbol) || name_or_hash.is_a?(String)
        name = name_or_hash.to_s.to_sym
        t = @@cache[name_or_hash]
        return t if t
        t = self.__new__ name
        return (@@cache[name_or_hash] = t) # assignment evaluates to t
      else
        # MILOD: I don't believe we want to cache these -- could result in clashes when we don't want them.
        #t = @@cache[name_or_hash]
        #return t if t

        t = self.__new__ name_or_hash

        #return (@@cache[name_or_hash] = t)
        return t
      end
    end

    def initialize(name_or_hash)
      if name_or_hash.is_a?(Symbol) || name_or_hash.is_a?(String)
        raise "weird" if name_or_hash.to_s == "expression"
        @name = name_or_hash
        @to_infer = false
        @path_sensitive = false
      elsif name_or_hash.is_a?(Hash)
        @to_infer = true
        @lbounds = []
        @ubounds = []
        @solution = nil

        ## `!!` here converts the value to true if it was truthy,
        ## and false if it was falsy or non-existent.
        @path_sensitive = !!name_or_hash[:path_sensitive] 


        @cls = name_or_hash[:cls]
        @name = name_or_hash[:name] ## might be nil if category is :ret
        @meth = name_or_hash[:meth] ## might be nil if ccategory is :var
        @category = name_or_hash[:category]

        if @category == :comp_type_output
          @comp_type_info = name_or_hash[:comp_type_info]
          RDL::Logging.log :inference, :trace, "Creating vartype for comp type output. cls=#{cls}"
        end
      else
        raise "Unexpected argument #{name_or_hash} to RDL::Type::VarType.new."
      end
    end


    ## Adds an upper bound to self, and transitively pushes it to all of self's lower bounds.
    # [+ typ +] is the Type to add as upper bound.
    # [+ pi +] is the Path under which we discovered this upper bound.
    # [+ ast +] is the AST where the bound originates from, used for error messages.
    # [+ new_cons +] is a Hash<VarType, Array<[:upper or :lower, Type, Path, AST]>>. When provided, can be used to roll back constraints in case an error pops up.
    # Path Sensitivity: this bound may have a pi. The bounds we are propagating to also may have pis. We will combine them here when recurring, so that the eventual call to `leq` has all the information.
    def add_and_propagate_upper_bound(typ, pi, ast, new_cons = {}, path_sensitive: true)
      return unless pi.satisfiable?
      # Try resolving any comp type output bounds.
      resolve_comp_type_output()
      # NOTE(Mark): this could be optimized by caching any comp-type bounds.
      @lbounds.each { |t, p, a| 
        t.resolve_comp_type_output()
      }
      @ubounds.each { |t, p, a| 
        t.resolve_comp_type_output()
      }

      # Self = Type variable T

      # If we add T <= T, do nothing
      return if self.equal?(typ)

      # If this upper bound doesn't already exist, add it to @ubounds.
      add_ubound(typ, pi, ast, new_cons)

      # For each lower bound,
      # TODO(Mark): propagate this bound accurately, according to the formalism.
      # TODO(Mark): do the same for `add_and_propagate_lower_bound`
      @lbounds.each { |lower_t, p, a|
        if typ.is_a?(VarType) && !typ.lbounds
          RDL::Logging.debug_error :inference, "Nil found in lbounds... Continuing"
          next
        end

        # Propagate upper bound (if we're inferring this lower bound type var)
        # Path Sensitivity: only propagate this bound if the lower_t is NOT
        # path-sensitive. Our formalism only guarantees subtyping transitivity
        # iff the paths are the same.
        if lower_t.is_a?(VarType) && lower_t.to_infer
          # Path Sensitivity: join paths. Bounds propagation will be terminated
          #                   as soon as the path becomes unsatisfiable.
          lower_t.add_and_propagate_upper_bound(typ, p.join(pi), ast, new_cons, path_sensitive: path_sensitive) unless lower_t.ubounds.any? { |t, p, _| t == typ }#&& p == pi }
        else
          # Here our lower_t was a REAL type.
          if typ.is_a?(VarType) && !typ.lbounds.any? { |t, p, _| t == lower_t }
            new_cons[typ] = new_cons[typ] ? new_cons[typ] | [[:lower, lower_t, p, ast]] : [[:lower, lower_t, p, ast]]
          end

          # Path Sensitivity: join paths. Bounds propagation will be terminated
          #                   as soon as the path becomes unsatisfiable.
          unless RDL::Type::Type.leq(lower_t, typ, p.join(pi), {}, false, ast: ast, no_constraint: true, propagate: true, new_cons: new_cons, path_sensitive: path_sensitive)
            d1 = a.nil? ? "" : (Diagnostic.new :note, :infer_constraint_error, [lower_t.to_s], a.loc.expression).render.join("\n")
            d2 = ast.nil? ? "" : (Diagnostic.new :note, :infer_constraint_error, [typ.to_s], ast.loc.expression).render.join("\n")
            raise RDL::Typecheck::StaticTypeError, ("Inconsistent type constraint #{lower_t} <=_{#{p.inspect}} #{typ} generated during inference.\n #{d1}\n #{d2}")
          end
        end
      }
    end

    ## Similar to above.
    def add_and_propagate_lower_bound(typ, pi, ast, new_cons = {}, path_sensitive: true)
      return unless pi.satisfiable?
      # Try resolving any comp type output bounds.
      resolve_comp_type_output()
      # NOTE(Mark): this could be optimized by caching any comp-type bounds.
      @lbounds.each { |t, p, a| 
        t.resolve_comp_type_output()
      }
      @ubounds.each { |t, p, a| 
        t.resolve_comp_type_output()
      }

      return if self.equal?(typ)
      #RDL::Logging.log :typecheck, :trace,  "#{typ} <=_{#{pi}} #{self}"

      add_lbound(typ, pi, ast, new_cons)

      RDL::Logging.log :typecheck, :trace, 'ubounds.each'
      @ubounds.each { |upper_t, p, a|
        if upper_t.is_a?(VarType) && !upper_t.lbounds
          RDL::Logging.debug_error :inference, "Nil found in upper_t.lbounds... Continuing"
          next
        end
        if typ.is_a?(VarType) && !typ.ubounds
          RDL::Logging.debug_error :inference, "Nil found in ubounds... Continuing"
          next
        end

        RDL::Logging.log :typecheck, :trace, "ubound: #{upper_t}"
        if upper_t.is_a?(VarType) && upper_t.to_infer 
          # Path Sensitivity: join paths. Bounds propagation will be terminated
          #                   as soon as the path becomes unsatisfiable.
          upper_t.add_and_propagate_lower_bound(typ, p.join(pi), ast, new_cons, path_sensitive: path_sensitive) unless upper_t.lbounds.any? { |t, p, _| t == typ }#&& p == pi }
        else
          # Here our upper_t was a REAL type.
          if typ.is_a?(VarType) && !typ.ubounds.any? { |t, _, _| t == upper_t }
            new_cons[typ] = new_cons[typ] ? new_cons[typ] | [[:upper, upper_t, p, ast]] : [[:upper, upper_t, p, ast]]
          end
          #RDL::Logging.log :typecheck, :trace, "about to check #{typ} <= #{upper_t} with".colorize(:green)

          #RDL::Util.each_leq_constraints(new_cons) { |a, b| RDL::Logging.log(:typecheck, :trace, "#{a} <= #{b}") }

          # Path Sensitivity: join paths. Bounds propagation will be terminated
          #                   as soon as the path becomes unsatisfiable.
          unless RDL::Type::Type.leq(typ, upper_t, p.join(pi), {}, false, ast: ast, no_constraint: true, propagate: true, new_cons: new_cons, path_sensitive: path_sensitive)
            d1 = ast.nil? ? "" : (Diagnostic.new :error, :infer_constraint_error, [typ.to_s], ast.loc.expression).render.join("\n")
            d2 = a.nil? ? "" : (Diagnostic.new :error, :infer_constraint_error, [upper_t.to_s], a.loc.expression).render.join("\n")
            raise RDL::Typecheck::StaticTypeError, ("Inconsistent type constraint #{typ} <=_{#{p.inspect}} #{upper_t} generated during inference.\n #{d1}\n #{d2}")
          end
          #RDL::Logging.log :typecheck, :trace, "Checked #{typ} <= #{upper_t}".colorize(:green)
        end
      }
    end

    def add_ubound(typ, pi, ast, new_cons = {}, propagate: false)
      return unless pi.satisfiable?
      #raise "About to add upper bound #{self} <= #{typ}" if typ.is_a?(VarType) && !typ.to_infer

      # If `typ` is a multitype, propagate each bound individually
      if typ.is_a? MultiType
        map = typ.map
        map.each { |upper_path, upper_t|
          add_ubound(upper_t, pi.join(upper_path), ast, new_cons, propagate: propagate)
        }
        # exit
        return
      end

      # Here `typ` is our real upper bound
      if propagate
        add_and_propagate_upper_bound(typ, pi, ast, new_cons)
      elsif !@ubounds.any? { |t, p, a| t == typ && p == pi }
        new_cons[self] = new_cons[self] ? new_cons[self] | [[:upper, typ, pi, ast]] : [[:upper, typ, pi, ast]]
        @ubounds << [typ, pi, ast] #unless @ubounds.any? { |t, a| t == typ }
      end
    end

    def add_lbound(typ, pi, ast, new_cons = {}, propagate: false)
      return unless pi.satisfiable?

      # If `typ` is a multitype, propagate each bound individually
      if typ.is_a? MultiType
        map = typ.map
        map.each { |lower_path, lower_t|
          add_ubound(lower_t, pi.join(lower_path), ast, new_cons, propagate: propagate)
        }
        # exit
        return
      end

      # Here `typ` is our real lower bound

      #raise "About to add lower bound #{typ} <= #{self}" if typ.is_a?(VarType) && !typ.to_infer
      # raise "ChoiceType!!!!" if typ.is_a? ChoiceType
      #RDL::Logging.log :typecheck, :trace, "#{self}.add_lbound(#{typ}); " + 'propagate'.colorize(:yellow) + " = #{propagate}"
      if propagate
        add_and_propagate_lower_bound(typ, pi, ast, new_cons)
      elsif !@lbounds.any? { |t, p, a| t == typ && p == pi }
        new_cons[self] = new_cons[self] ? new_cons[self] | [[:lower, typ, pi, ast]] : [[:lower, typ, pi, ast]]
        @lbounds << [typ, pi, ast] #unless @lbounds.any? { |t, a| t == typ }
      end
    end

    def to_s # :nodoc:
      if @to_infer
        return 'XXX' if @@print_XXX

        "{ #{@cls}##{@meth} #{@category}: #{@name} }"
      else
        @name.to_s
      end
    end

    def base_name
      return nil unless @name
      ## if var represents returned value, then method name is closest thing we have to variable's name.
      if @category == :ret then @meth.to_s else @name.to_s.delete("@") end
    end

    ## This is for global/class/instance variables.
    ## When we observe these vars in a method, we keep track of
    ## which class/method we saw it in.
    def add_method_use(klass, meth)
      raise "Expected category to be :var, got {@category}" unless @category == :var
      klass = klass.to_s
      meth = meth.to_s
      @meths_using_var = @meths_using_var << [klass, meth] unless @meths_using_var.include?([klass, meth])
    end

    def ==(other)
      return false if other.class != self.class
      other = other.canonical
      return (other.instance_of? self.class) && other.to_s == to_s#(other.name.to_s == @name.to_s)
    end

    alias eql? ==

    # an uninstantiated variable is only comparable to itself
    def <=(other)
      return Type.leq(self, other)
    end

    def match(other, type_var_table = {})
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType

      return true if other.instance_of? WildQuery
      return false unless other.instance_of? VarType

      name_sym = name.to_sym

      # If we've seen this type variable before, look up what it was originally
      # referencing and test that for equality with the current `other` type
      return type_var_table[name_sym] == other if type_var_table.key? name_sym

      # Otherwise, store the other type and return true.
      type_var_table[name_sym] = other
      true
    end

    # To be called during constraint resolution.
    # Re-Executes this comp type. If its result is not a string, we will
    # propagate that as a bound in both directions.
    def resolve_comp_type_output()
      # Should probably hash this.
      return unless @category == :comp_type_output
      return if @solution

      hash = @comp_type_info

      tactuals = hash[:comp_type_tactuals].map { |t| 
        if (t.is_a? VarType)
          # Extract solution if arg is a vartype
          RDL::Typecheck.extract_var_sol(t, t.category)
        else
          t
        end
      }

      # Run the Comp Type
      # hash is Hash<{comp_type_meth: MethodType, comp_type_tactuals: Type[], self_klass: Class, trecv: Type}>
      fallback_output = comp_type_info[:fallback_output]
      binds = RDL::Typecheck.tc_bind_arg_types(hash[:comp_type_meth], tactuals)
      tmeth = RDL::Typecheck.compute_types(hash[:comp_type_meth], hash[:self_klass], hash[:trecv], tactuals, binds) unless binds.nil?

      # [ ] is output different than the fallback output type?
      #     yes -> add and propagate that as a bound
      #      no -> move on
      if !(tmeth.ret.equal?(fallback_output)) && (!@solution)
        @solution = tmeth.ret
        add_and_propagate_upper_bound(@solution, Path.new, nil)
        add_and_propagate_lower_bound(@solution, Path.new, nil)
      end
    end

    def hash # :nodoc:
      return to_s.hash#@name.to_s.hash
    end

    def member?(obj, vars_wild: false)
      return true if vars_wild
      raise TypeError, "Unbound type variable #{@name}"
    end

    def instantiate(inst)
      return inst[@name] if inst[@name]
      return self
    end

    def widen
      return self
    end

    def copy
      self
    end

    def self.print_XXX!
      @@print_XXX = true
    end

    def self.no_print_XXX!
      @@print_XXX = false
    end

  end
end
