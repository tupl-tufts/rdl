#!/usr/bin/env ruby

require 'rdl'
require 'rdl_types'

#array = Fixnum.instance_methods(false)

def check_one(cl) #checks class for missing methods
	array_one = cl.instance_methods(false)
	array_one.each{ |t|
		if query(cl.to_s+'#'+t.to_s)==nil 
		puts t end}
end

def check_two(cl) #checks class for methods which are actually inherited
	array_one = cl.instance_methods(false)
	array_two = class_query(cl)
	array_two.each{ |t|
		if !array_one.include?(t) then puts t end}
end

  def class_query(q)
    klass = q.to_s
    return nil unless $__rdl_contracts.has_key? klass
    cls_meths = []
    cls_klass = RDL::Util.add_singleton_marker(klass)
    if $__rdl_contracts.has_key? cls_klass then
      $__rdl_contracts[cls_klass].each { |meth, kinds|
        if kinds.has_key? :type then
          kinds[:type].each { |t| cls_meths << meth }
        end
      }
    end
    inst_meths = []
    if $__rdl_contracts.has_key? klass then
      $__rdl_contracts[klass].each { |meth, kinds|
        if kinds.has_key? :type then
          kinds[:type].each { |t| inst_meths << meth }
        end
      }
    end
    cls_meths.sort! { |p1, p2| p1[0] <=> p2[0] }
    cls_meths.each { |m, t| m.insert(0, "self.") }
    inst_meths.sort! { |p1, p2| p1[0] <=> p2[0] }
    return cls_meths + inst_meths
  end

def query(q)
    $__rdl_contract_switch.off {
      if q =~ /^(\w+(#|\.))?(\w+(!|\?|=)?|!|~|\+|\*\*|-|\*|\/|%|<<|>>|&|\||\^|<|<=|=>|>|==|===|!=|=~|!~|<=>|\[\]|\[\]=)$/
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
        if RDL::Wrap.has_contracts?(klass, meth, :type)
          typs = RDL::Wrap.get_contracts(klass, meth, :type)
          typs.each { |t|
            #puts "#{klass_pref}#{meth}: #{t}"
	    t_string = "#{t}"
	    t_string =~ /\((\w*)\)(.+)/
	
	    #puts y
	    return t_string
	    #return "#{t}" 
          }
          nil
        else
          nil
        end
      else
        nil
      end
    }
  end
