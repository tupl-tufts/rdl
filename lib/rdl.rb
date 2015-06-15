require 'set'

require_relative 'rdl/master_switch'
#require_relative 'rdl_ctc'
require_relative 'rdl_sig'
require_relative 'rdl_dsl'
require_relative 'rdl_rdc'
require_relative 'rdl/types'
require_relative 'rdl/contracts'
require_relative 'rdl/turn_off'

class Object
  def self.method_added(mname)
    specs = self.instance_variable_get :@__deferred_specs

    if specs and specs.keys.include? mname
      sm = specs[mname]
      specs.delete mname
      sm.each {|args, blk| self.spec(mname, *args, &blk)}
    end
  end
end

module RDL
  @@master_switch = true

  def self.get_type(m)
    if m.include?('#')
      s = m.split('#')
      cls = eval(s[0])
      nt = RDL::Type::NominalType.new(cls)
    elsif m.include?('.')
      s = m.split('.')
      cls = eval(s[0])
      nt = eval("#{s[0]}.rdl_type")
    else
      raise Exception, "argument to get_type must be or the form \"Talks#list\" or \"Talks.list\""
    end

    m = s[1]
    nt.get_method(m.to_sym)
  end

#  def keyword(mname, *args, &blk)
#    Lang.new(self).keyword(mname, *args, &blk)
#  end

#  alias :entry :keyword

  def type_params(*t_params)
    return if t_params.empty?

    t_parameters = []

    iterators = {}
    t_params.each {
      |pair|
      t_parameters << pair[0]
      if pair.length == 1
        iterators[pair[0]] = nil
      else
        iterators[pair[0]] = pair[1]
      end
    }

    t_parameters.map! {|p| RDL::Type::VarType.new(p)}
    self.instance_variable_set :@__cls_params, iterators
  end

  def spec(mname, *args, &blk)
    mname = mname.to_sym

#    if self.instance_methods(false).include? mname
#      Lang.new(self).spec(mname, *args, &blk)
#    else
      deferred_specs = self.instance_variable_get(:@__deferred_specs)
      deferred_specs[mname] = [] if not deferred_specs.keys.include? mname
      deferred_specs[mname].push([args, blk])
#    end
  end

# Typesig annotations for method types
#B TODO: allow both optional meta and splat *pre/postconds
def typesig(mname, sig, meta={})
    Object.new.typesig(self, mname, sig, meta)
end

# Pre condition generator for use in :typesig annotations
def pre(desc=nil,&blk)
    PreCtc.new(RootCtc.new(desc,&blk))
end

# Post condition generator for use in :typesig annotations
def post(desc=nil,&blk)
    PostCtc.new(RootCtc.new(desc,&blk))
end

#
def self.create_spec(&b)
    Proc.new &b
end

#
def self.state
    @state = {} unless @state
    @state
end

#
def self.extended(extendee)
  extendee.instance_variable_set(:@__deferred_specs, {})
  extendee.instance_variable_set(:@__cls_params, {})
  extendee.instance_variable_set(:@__typesigs, {})
end

def rdocTypesigFor(klass)
    tmp = RDLdocObj.new
    tmp.add_klass(klass)
    tmp.rdoc_gen
end


end #End of Module:RDL


class Object
  # Handles internal typesig routing
  # See rdl_sig.rb
  #B TODO: See RDL::typesig()
  def typesig(cls, mname, sig, meta={})
    if cls.class == Symbol
      cls = eval(cls.to_s)
    elsif cls.class == String
      cls = eval(cls)
    end
    
    cls.instance_eval do
      extend RDL if not cls.singleton_class.included_modules.include?(RDL)
      spec mname.to_sym do
        typesig sig, meta
      end
    end
  end
  
  def rdocTypesigFor(klass)
    
  end
end

status = RDL.on?
RDL.turn_off if status

begin
  # stops RDL code from checking itself and eliminates
  # the old RTC NativeArray, NativeHash, etc.
  RDL::TurnOffCheck.turn_off_check
ensure
  RDL.turn_on if status
end
