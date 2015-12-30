class RDL::Query

  # Return a pair [name, array of the types] for the method specified by q. Valid specifiers are:
  # Class#method - instance method
  # Class.method - class method
  # method - method of self's class
  def self.method_query(q)
    $__rdl_contract_switch.off {
#      if q =~ /^(\w+(#|\.))?(\w+(!|\?|=)?|!|~|\+|\*\*|-|\*|\/|%|<<|>>|&|\||\^|<|<=|=>|>|==|===|!=|=~|!~|<=>|\[\]|\[\]=)$/
      klass = nil
      klass_pref = nil
      meth = nil
      if q =~ /(.+)#(.+)/
        klass = $1
        klass_pref = "#{klass}#"
        meth = $2.to_sym
      elsif q =~ /(.+)\.(.+)/
        klass_pref = "#{$1}."
        klass = RDL::Util.add_singleton_marker($1)
        meth = $2.to_sym
      else
        klass = self.class.to_s
        klass_pref = "#{klass}#"
        meth = q.to_sym
      end
      name = "#{klass_pref}#{meth}"
      if RDL::Wrap.has_contracts?(klass, meth, :type)
        return [name, RDL::Wrap.get_contracts(klass, meth, :type)]
      else
        raise "No type for #{name}"
      end
#      else
#        raise "Not implemented"
#      end
    }
  end

end
