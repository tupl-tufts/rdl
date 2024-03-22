module RDL::Type
  class VarType < Type
    attr_reader :name, :cls, :meth, :category, :to_infer, :path_sensitive
    attr_accessor :lbounds, :ubounds, :solution, :solution_source

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

        #if @path_sensitive
        #  require 'debug/open'
        #end


        @cls = name_or_hash[:cls]
        @name = name_or_hash[:name] ## might be nil if category is :ret
        @meth = name_or_hash[:meth] ## might be nil if ccategory is :var
        @category = name_or_hash[:category]
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
    def add_and_propagate_upper_bound(typ, pi, ast, new_cons = {})
      # Self = Type variable T

      # If we add T <= T, do nothing
      return if self.equal?(typ)


      # If this upper bound doesn't already exist, add it to @ubounds.
      if !@ubounds.any? { |t, p, a| t == typ }
        # Path Sensitivity: Using `pi` here because there is no "other" bound to combine with.
        @ubounds << [typ, pi, ast]
        new_cons[self] = new_cons[self] ? new_cons[self] | [[:upper, typ, pi, ast]] : [[:upper, typ, pi, ast]]
      end

      # For each lower bound,
      # TODO(Mark): propagate this bound accurately, according to the formalism.
      # TODO(Mark): do the same for `add_and_propagate_lower_bound`
      @lbounds.each { |lower_t, p, a|
        p = p.concat(pi)
        if typ.is_a?(VarType) && !typ.lbounds
          RDL::Logging.debug_error :inference, "Nil found in lbounds... Continuing"
          next
        end

        # Propagate upper bound (if we're inferring this lower bound type var)
        # Path Sensitivity: only propagate this bound if the lower_t is NOT
        # path-sensitive. Our formalism only guarantees subtyping transitivity
        # iff the paths are the same.
        if lower_t.is_a?(VarType) && lower_t.to_infer && !lower_t.path_sensitive
          lower_t.add_and_propagate_upper_bound(typ, p, ast, new_cons) unless lower_t.ubounds.any? { |t, _, _| t == typ }
        else

          # 
          if typ.is_a?(VarType) && !typ.lbounds.any? { |t, p, _| t == lower_t }
            p = p.concat(pi)
            new_cons[typ] = new_cons[typ] ? new_cons[typ] | [[:lower, lower_t, p, ast]] : [[:lower, lower_t, p, ast]]
          end
          unless RDL::Type::Type.leq(lower_t, typ, p, {}, false, ast: ast, no_constraint: true, propagate: true, new_cons: new_cons)
            d1 = a.nil? ? "" : (Diagnostic.new :note, :infer_constraint_error, [lower_t.to_s], a.loc.expression).render.join("\n")
            d2 = ast.nil? ? "" : (Diagnostic.new :note, :infer_constraint_error, [typ.to_s], ast.loc.expression).render.join("\n")
            raise RDL::Typecheck::StaticTypeError, ("Inconsistent type constraint #{lower_t} <=_{#{p}} #{typ} generated during inference.\n #{d1}\n #{d2}")
          end
        end
      }
    end

    ## Similar to above.
    def add_and_propagate_lower_bound(typ, pi, ast, new_cons = {})
      return if self.equal?(typ)
      #RDL::Logging.log :typecheck, :trace,  "#{typ} <=_{#{pi}} #{self}"
      # Path Sensitivity: On the next line, do we need to check path as well?
      if !@lbounds.any? { |t, p, a| t == typ }
        RDL::Logging.log :typecheck, :trace,  '@lbounds.any'
        @lbounds << [typ, pi, ast]
        new_cons[self] = new_cons[self] ? new_cons[self] | [[:lower, typ, pi, ast]] : [[:lower, typ, pi, ast]]
      end
      RDL::Logging.log :typecheck, :trace, 'ubounds.each'
      @ubounds.each { |upper_t, p, a|
        p = p.concat(pi)
        if upper_t.is_a?(VarType) && !upper_t.lbounds
          RDL::Logging.debug_error :inference, "Nil found in upper_t.lbounds... Continuing"
          next
        end
        if typ.is_a?(VarType) && !typ.ubounds
          RDL::Logging.debug_error :inference, "Nil found in ubounds... Continuing"
          next
        end

        RDL::Logging.log :typecheck, :trace, "ubound: #{upper_t}"
        if upper_t.is_a?(VarType)
          upper_t.add_and_propagate_lower_bound(typ, p, ast, new_cons) unless upper_t.lbounds.any? { |t, _, _| t == typ }
        else
          if typ.is_a?(VarType) && !typ.ubounds.any? { |t, _, _| t == upper_t }
            new_cons[typ] = new_cons[typ] ? new_cons[typ] | [[:upper, upper_t, p, ast]] : [[:upper, upper_t, p, ast]]
          end
          #RDL::Logging.log :typecheck, :trace, "about to check #{typ} <= #{upper_t} with".colorize(:green)

          #RDL::Util.each_leq_constraints(new_cons) { |a, b| RDL::Logging.log(:typecheck, :trace, "#{a} <= #{b}") }

          unless RDL::Type::Type.leq(typ, upper_t, p, {}, false, ast: ast, no_constraint: true, propagate: true, new_cons: new_cons)
            d1 = ast.nil? ? "" : (Diagnostic.new :error, :infer_constraint_error, [typ.to_s], ast.loc.expression).render.join("\n")
            d2 = a.nil? ? "" : (Diagnostic.new :error, :infer_constraint_error, [upper_t.to_s], a.loc.expression).render.join("\n")
            raise RDL::Typecheck::StaticTypeError, ("Inconsistent type constraint #{typ} <= #{upper_t} generated during inference.\n #{d1}\n #{d2}")
          end
          #RDL::Logging.log :typecheck, :trace, "Checked #{typ} <= #{upper_t}".colorize(:green)
        end
      }
    end

    def add_ubound(typ, pi, ast, new_cons = {}, propagate: false)
      #raise "About to add upper bound #{self} <= #{typ}" if typ.is_a?(VarType) && !typ.to_infer
      if propagate
        add_and_propagate_upper_bound(typ, pi, ast, new_cons)
      elsif !@ubounds.any? { |t, p, a| t == typ }
        new_cons[self] = new_cons[self] ? new_cons[self] | [[:upper, typ, pi, ast]] : [[:upper, typ, pi, ast]]
        @ubounds << [typ, pi, ast] #unless @ubounds.any? { |t, a| t == typ }
      end
    end

    def add_lbound(typ, pi, ast, new_cons = {}, propagate: false)
      #require 'debug/open'
      if pi == nil
        print "we got a problem here"
      end
      #raise "About to add lower bound #{typ} <= #{self}" if typ.is_a?(VarType) && !typ.to_infer
      # raise "ChoiceType!!!!" if typ.is_a? ChoiceType
      #RDL::Logging.log :typecheck, :trace, "#{self}.add_lbound(#{typ}); " + 'propagate'.colorize(:yellow) + " = #{propagate}"
      if propagate
        add_and_propagate_lower_bound(typ, pi, ast, new_cons)
      elsif !@lbounds.any? { |t, p, a| t == typ }
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
