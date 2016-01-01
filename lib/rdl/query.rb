class RDL::Query

  # Return a pair [name, array of the types] for the method specified by q. Valid queries are:
  # Class#method - instance method
  # Class.method - class method
  # method - method of self's class
  def self.method_query(q)
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
  end

  # Return an ordered list of all method types of a class. The query should be a class name.
  def self.class_query(q)
    klass = q.to_s
    return [] unless $__rdl_contracts.has_key? klass
    cls_meths = []
    cls_klass = RDL::Util.add_singleton_marker(klass)
    if $__rdl_contracts.has_key? cls_klass then
      $__rdl_contracts[cls_klass].each { |meth, kinds|
        if kinds.has_key? :type then
          kinds[:type].each { |t| cls_meths << [meth.to_s, t] }
        end
      }
    end
    inst_meths = []
    if $__rdl_contracts.has_key? klass then
      $__rdl_contracts[klass].each { |meth, kinds|
        if kinds.has_key? :type then
          kinds[:type].each { |t| inst_meths << [meth.to_s, t] }
        end
      }
    end
    cls_meths.sort! { |p1, p2| p1[0] <=> p2[0] }
    cls_meths.each { |m, t| m.insert(0, "self.") }
    inst_meths.sort! { |p1, p2| p1[0] <=> p2[0] }
    return cls_meths + inst_meths
  end

  # Returns sorted list of pairs [method name, type] matching query. The query should be a string containing a method type query.
  def self.method_type_query(q)
    q = $__rdl_parser.scan_str "#Q #{q}"
    result = []
    $__rdl_contracts.each { |klass, meths|
      meths.each { |meth, kinds|
        if kinds.has_key? :type then
          kinds[:type].each { |t|
            if q.match(t)
              result << [RDL::Util.pretty_name(klass, meth), t]
            end
          }
        end
      }
    }
    result.sort! { |p1, p2| p1[0] <=> p2[0] }
    return result
  end

end

class Object

  def rdl_query(q)
    $__rdl_contract_switch.off {
      if q =~ /^[A-Z]\w*(#|\.)([a-z_]\w*(!|\?|=)?|!|~|\+|\*\*|-|\*|\/|%|<<|>>|&|\||\^|<|<=|=>|>|==|===|!=|=~|!~|<=>|\[\]|\[\]=)$/
        name, typs = RDL::Query.method_query(q)
        typs.each { |t|
          puts "#{name}: #{t}"
        }
      elsif q =~ /^[A-Z]\w*$/
        RDL::Query.class_query(q).each { |m, t| puts "#{m}: #{t}"}
      elsif q =~ /\(.*\)/
        RDL::Query.method_type_query(q).each { |m, t| puts "#{m}: #{t}" }
      else
        raise "Don't know how to handle query"
      end
      nil
    }
  end

end
