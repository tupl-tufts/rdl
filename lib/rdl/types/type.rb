module RDL::Type
  # Abstract base class for all types. This class
  # should never be instantiated directly.
  class Type
    def le(other, h={})
      case other
      when TopType
        true
      when NilType
        false
      when SymbolType
        false
      when IntersectionType
        raise Exception, "Should not be called"
      when UnionType
        solution_found = false

        other.types.each {|o|
          if self.le(o, h) 
            if solution_found
              raise RDL::AmbiguousUnionException, "Ambiguous comparison of #{self.inspect} and #{other.inspect}"
            end

            solution_found = true
          end
        }
        
        solution_found
      else
        raise "NOT implemented for NamedType self=#{self.inspect}  other=#{other.inspect}"
      end
    end

    def parameterized?
      false
    end

    def replace_vartypes(type_vars)
      map {|t| t.replace_vartypes(type_vars)}
    end

    def map
      raise "this method should be implemented each subclass"
    end

    def get_vartypes(a = []) 
      self.each {|ti|
        if self != ti
          ti.get_vartypes(a)
        else
          a.push(ti.name.to_sym) if ti.instance_of? RDL::Type::VarType
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
  end
end

