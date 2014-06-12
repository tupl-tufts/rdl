require_relative '../rdl'

module RDL::Type
  # Abstract base class for all types. This class
  # should never be instantiated directly.
  class Type
    def parameterized?
      false
    end

    def replace_parameters(type_vars)
      map {|t| t.replace_parameters(type_vars)}
    end

    def map
      raise "this method should be implemented each subclass"
    end

    def get_method_parameters(a = RDL::NativeArray.new)
      self.each {|ti|
        if self != ti
          ti.get_method_parameters(a)
        else
          a.push(ti.symbol) if ti.instance_of? RDL::Type::TypeParameter
        end
      }
      
      a.uniq
    end

    def has_variables
      self.each {|t|        
        return true if t.is_a?(RDL::Type::TypeVariable) and t.solving?
        t.has_variables unless t.is_terminal
      }
      false
    end

    def is_tuple
      false
    end
    
    def to_actual_type
      if not defined?(@actual_type)
        @actual_type = _to_actual_type
      end
      @actual_type
    end

    def _to_actual_type
      map {|t| 
        t.to_actual_type
      }
    end
    
    # Return true if +self+ is a subtype of +other+. Implemented in
    # subclasses.
    def <=(other)
      case other
      when UnionType
        if other.has_variables
          solution_found = false
          for i in other.types
            if self <= i
              raise Exception, "Ambiguous union detected" if solution_found
              solution_found = true
            end
          end
          solution_found
        else
          other.types.any? do |a|
            self <= a
          end
        end
      when IntersectionType
        other.types.any? do |a|
          self <= a
        end
      when TypeVariable
        return self <= other.get_type if other.instantiated
        return false unless other.solving             
        other.add_constraint(self)
        true
      when TopType
        true
      when TupleType
        raise Exception, '<= TupleType NOT implemented'
      else
        false
      end
    end
  end
end

