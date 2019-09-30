module RDL::Type
  class VarType < Type
    attr_reader :name, :cls, :meth, :category, :to_infer
    attr_accessor :lbounds, :ubounds, :solution
    
    @@cache = {}

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
        @name = name_or_hash
        @to_infer = false
      elsif name_or_hash.is_a?(Hash)
        @to_infer = true
        @lbounds = []
        @ubounds = []
        @solution = nil
        
        @cls = name_or_hash[:cls]
        @name = name_or_hash[:name] ## might be nil if category is :ret
        @meth = name_or_hash[:meth] ## might be nil if ccategory is :var
        @category = name_or_hash[:category]
      else
        raise "Unexpected argument #{name_or_hash} to RDL::Type::VarType.new."
      end
    end


    def add_and_propagate_upper_bound(typ, ast)
      return if self.equal?(typ)
      @ubounds << [typ, ast] if !ubounds.any? { |t, a| t == typ }
      #typ.ubounds.each { |t| add_and_propagate_upper_bound(typ) }
      @lbounds.each { |lower_t, a|
        if lower_t.is_a?(VarType)
          lower_t.add_and_propagate_upper_bound(typ, ast)
        else
          puts "1. ABOUT TO COMPARE #{lower_t} TO #{typ} " if @meth == :random_secrets
          unless RDL::Type::Type.leq(lower_t, typ, {}, false, ast: ast, no_constraint: true)
            d1 = a.nil? ? "" : (Diagnostic.new :note, :infer_constraint_error, [lower_t.to_s], a.loc.expression).render.join("\n")
            d2 = ast.nil? ? "" : (Diagnostic.new :note, :infer_constraint_error, [typ.to_s], ast.loc.expression).render.join("\n")
            raise RDL::Typecheck::StaticTypeError, ("Inconsistent type constraint #{lower_t} <= #{typ} generated during inference.\n #{d1}\n #{d2}")
          end
        end
      }
    end

    def add_and_propagate_lower_bound(typ, ast)
      return if self.equal?(typ)
      @lbounds << [typ, ast] if !@lbounds.any? { |t, a| t == typ }
      #typ.lbounds.each { |t| add_and_propagate_lower_bound(typ) } if typ.is_a?(VarType)
      @ubounds.each { |upper_t, a|
        if upper_t.is_a?(VarType)
          upper_t.add_and_propagate_lower_bound(typ, ast)
        else
          puts "2. ABOUT TO COMPARE #{typ} TO #{upper_t} " if @meth == :random_secrets
          unless RDL::Type::Type.leq(typ, upper_t, {}, false, ast: ast, no_constraint: true)
            d1 = ast.nil? ? "" : (Diagnostic.new :error, :infer_constraint_error, [typ.to_s], ast.loc.expression).render.join("\n")
            d2 = a.nil? ? "" : (Diagnostic.new :error, :infer_constraint_error, [upper_t.to_s], a.loc.expression).render.join("\n")
            raise RDL::Typecheck::StaticTypeError, ("Inconsistent type constraint #{typ} <= #{upper_t} generated during inference.\n #{d1}\n #{d2}")
          end
        end
      }
    end

    def to_s # :nodoc:
      if @to_infer
        if @solution
          return @solution.to_s
        else
          return "{ #{@cls}##{@meth} #{@category}: #{@name} }"
        end
      else
        return @name.to_s
      end
    end

    def base_name
      return nil unless @name
      @name.to_s.delete("@")
    end

    def ==(other)
      return false if other.nil?
      other = other.canonical
      return (other.instance_of? self.class) && (other.name.to_s == @name.to_s)
    end

    alias eql? ==

    # an uninstantiated variable is only comparable to itself
    def <=(other)
      return Type.leq(self, other)
    end

    def match(other)
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return self == other
    end

    def hash # :nodoc:
      return @name.to_s.hash
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

  end
end
