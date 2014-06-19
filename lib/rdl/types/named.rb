require_relative 'type'
require_relative 'native'

module RDL::Type::NamedType
  def self.included(base)
    s = <<END
      attr_reader :name
      attr_reader :klass

      @@cache = RDL::NativeHash.new

      class << self
        alias :__new__ :new
      end

      def self.new(name)
        if (name.class != String) and (name.class != Symbol)
          klass = name
        end

        name = name.to_s.to_sym

        t = @@cache[name]
        if not t
          t = self.__new__ name, klass
          @@cache[name] = t
        end

        return t
      end
END
      base.class_eval s
  end

  def initialize(name, klass=nil)
    @name = name
    @klass = klass
    @type_parameters = []
  end

  def to_s # :nodoc:
    return @name.to_s
  end

  def eql?(other)
    self == other
  end

  def ==(other)
    return (other.instance_of? self.class) && (other.name == @name)
  end

  def hash # :nodoc:
    return @name.hash
  end

  def type_parameters
    @type_parameters
  end

  def type_parameters=(t_params)
    @type_parameters = t_params
  end
end

module RDL::Type
  class NominalType < Type
    include TerminalType
    include NamedType

    def each
    end
    
    def <=(other)
      case other
      when NominalType
        s_type = self.klass
        o_type = other.klass

        if s_type == nil 
          s_type = eval(self.name.to_s)
        end

        if o_type == nil 
          o_type = eval(other.name.to_s)
        end
        
        if s_type == nil or o_type == nil
          raise Exception, "Not implemented   #{self.inspect}  #{other.inspect}"
        end
        
        s_type <= o_type
      when GenericType
        false
      when TupleType
        false
      when TopType
        true
      when StructuralType
        super(other)
      else
        super(other)
      end
    end

    def add_method_type(name, type)
      @method_types ||= {}

      if @method_types[name]
        extant_type = @method_types[name]

        if extant_type.instance_of?(IntersectionType)
          type = [type] + extant_type.types.to_a
        else
          type = [type, extant_type]
        end
        type = IntersectionType.new(*type)
      end

      @method_types[name] = type
    end

    def get_method(name, which = nil, type_subst = nil)
      klass = eval(@name.to_s)
      it = self

      if which
        while it and which != it.klass
          it = it.superclass
        end
        if it.nil?
          return nil
        end
        type_hash = it.method_types
        if m_type = type_hash[name]
          m_type.is_a?(IntersectionType) ?
          m_type.map { |m| m.instantiate(type_subst) } :
            m_type.instantiate(type_subst)
        else
          nil
        end
      else
        found = false

        klass.ancestors.each {|a|
          it = RDL::Type::NominalType.new(a)
          
          if it.method_types.has_key?(name)
            found = true
            break
          end
        }
        
        it = nil if not found

        if klass.ancestors[0] != klass
          it = self

          while it and not it.method_types.has_key?(name)
            it = it.superclass
          end
        end
        
        return nil if it.nil?

        m_type = it.method_types[name]

        m_type.is_a?(IntersectionType) ? m_type.map { |m| m.instantiate(type_subst) } :
          m_type.instantiate(type_subst)
      end
    end    
    
    def method_types
      @method_types ? @method_types : {}
    end

    def map
      self
    end

    def inspect
      "NominalType<#{@name}>"
    end
  end

  class SymbolType < Type
    include NamedType
    include TerminalType
    
    def each
      yield self
    end

    def map
      self
    end

    def to_s
      ":#{@name}"
    end
    
    def <=(other)
      if other.instance_of?(SymbolType)
        self == other
      elsif other.instance_of?(NominalType) and other.name.to_s == "Symbol"
        true
      else
        super
      end
    end
  end

  class VarType < Type
    include NamedType
  end
end
