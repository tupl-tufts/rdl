require 'set'

class Range
  alias :old_initialize :initialize
  
  def initialize(*args)
    old_initialize(*args)
  end

  def no_iter
    []
  end

  def step_iter(step_num)
    self.step(step_num)
  end

  def random_iter(iter = (self.max - self.min) / 2)
    rand_set = Set.new
    prng = Random.new
    
    while rand_set.size < iter
      rand_set.add(prng.rand(self.min..self.max))
    end

    rand_set.to_a
  end
end

module RDL
  @@master_switch = true

  class << self
    attr_accessor :print_warning
  end

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





  def keyword(mname, *args, &blk)
    Lang.new(self).keyword(mname, *args, &blk)
  end

  alias :entry :keyword

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

    t_parameters.map! {|p| RDL::Type::TypeParameter.new(p)}
    
    RDL::Type::NominalType.new(self).type_parameters = t_parameters
    define_iterators(iterators)
  end

  def define_iterator(param_name,iterator_name)
    rtc_meta.fetch(:iterators)[param_name] = iterator_name
  end

  def define_iterators(iter_hash)
    rtc_meta.fetch(:iterators).merge!(iter_hash)
  end
  
  def spec(mname, *args, &blk)
    Lang.new(self).spec(mname, *args, &blk)
  end

  def typesig(mname, sig, meta={})
    Object.new.typesig(self, mname, sig, meta)
  end

  def self.create_spec(&b)
    Proc.new &b
  end

  def self.state
    @state = {} unless @state
    @state
  end

  def self.extended(extendee)
    extendee.instance_variable_set(:@typesig_info, {})
    #extendee.instance_variable_set(:@deferred_specs, {})
  end
end

class Object
  def typesig(cls, mname, sig, meta={})
    if cls.class == Symbol
      cls = eval(cls.to_s)
    elsif cls.class == String
      cls = eval(cls)
    end

    typesig_call = "
      extend RDL if not #{cls}.singleton_class.included_modules.include?(RDL)
      spec :#{mname.to_s} do
        typesig(\"#{sig}\", #{meta})
      end"
    
    #    if cls.instance_methods(false).include?(mname)
    cls.instance_eval(typesig_call)
    #   else
    #     dss = cls.instance_variable_get(:@deferred_specs)
    #     dss[mname] = typesig_call
    #   end
  end
end


#RDL.print_warning = false
#status = RDL::MasterSwitch.is_on?
#RDL::MasterSwitch.turn_off if status
require_relative 'rdl/types'
#require_relative 'type/base_types'
#RDL::MasterSwitch.turn_on if status


