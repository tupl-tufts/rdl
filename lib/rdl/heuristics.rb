class RDL::Heuristic

  @rules = {}

  @meth_cache = {}

  @meth_to_cls_map = Hash.new {|hash, m| hash[m] = Set.new}  # maps a method to a set of classes with that method
  @str_to_cls_map = {}  # this is needed to avoid calling the hash function on classes since hash can be overridden.
  # RDL::Util.to_class does not always work adequately for deprecetaed modules/methods, hence the need for this map.

  def self.init_meth_to_cls  # to be called before the first call to struct_to_nominal
    ObjectSpace.each_object(Module).each do |c|
      @str_to_cls_map[c.to_s] = c
      class_methods = c.instance_methods | RDL::Globals.info.get_methods_from_class(c.to_s)
      class_methods.each {|m| @meth_to_cls_map[m] = @meth_to_cls_map[m].add(c.to_s)}
    end
  end

  def self.add(name, &blk)
    raise RuntimeError, "Expected heuristic name to be Symbol, given #{name}." unless name.is_a? Symbol
    raise RuntimeError, "Expected block to be provided for heuristic." if blk.nil?
    @rules[name] = blk
  end

  def self.matching_classes(meth_names)
    meth_names.delete(:initialize)
    meth_names.delete(:new)

    # meth_names = meth_names.sort  # otherwise cache works almost only when meth_names.size == 1
    if @meth_cache.key? meth_names
      RDL::Logging.log :heuristic, :trace, "Cache used to find %d matching classes" % @meth_cache[meth_names].size
      return @meth_cache[meth_names]
    end

    init_meth_to_cls if @meth_to_cls_map.empty?  # initialize @meth_to_cls on first call to matching_classes

    # matching_classes = meth_names.map {|m| @meth_to_cls_map[m]}.reduce(:&).to_a  # faster but does not allow debugging
    matching_classes = @meth_to_cls_map[meth_names[0]]
    meth_names[1..-1].each_with_index do |m, index|
      tmp = matching_classes.intersection(@meth_to_cls_map[m])
      if tmp.empty? && !matching_classes.empty?
        RDL::Logging.log :heuristic, :trace,
                         "Found %d matching classes for methods: %s, but none of these classes have method %s" %
                             [matching_classes.size, meth_names[0..index] * ", ", m]
      end
      matching_classes = tmp
    end

    matching_classes = matching_classes.map {|c| @str_to_cls_map[c]}
    RDL::Logging.log :heuristic, :trace, "Overall, found %d matching classes" % matching_classes.size
    @meth_cache[meth_names] = matching_classes
    matching_classes
  end

  def self.struct_to_nominal(var_type)
    return unless (var_type.category == :arg) || (var_type.category == :var)#(var_type.category == :ivar) || (var_type.category == :cvar) || (var_type.category == :gvar) ## this rule only applies to args and (instance/class/global) variables
    #return unless var_type.ubounds.all? { |t, loc| t.is_a?(RDL::Type::StructuralType) || t.is_a?(RDL::Type::VarType) } ## all upper bounds must be struct types or var types
    return unless var_type.ubounds.any? { |t, loc| t.is_a?(RDL::Type::StructuralType) } ## upper bounds must include struct type(s)
    struct_types = var_type.ubounds.select { |t, loc| t.is_a?(RDL::Type::StructuralType) }
    struct_types.map! { |t, loc| t }
    RDL::Logging.log :heuristic, :trace, "Found %d upper bounds of structural type" % struct_types.size
    return if struct_types.empty?
    meth_names = struct_types.map { |st| st.methods.keys }.flatten.uniq
    meth_names.delete(:initialize)
    meth_names.delete(:new)
    return if meth_names.empty?
    RDL::Logging.log :heuristic, :trace, "Corresponding methods are: %s" % (meth_names*", ")
    matching_classes = matching_classes(meth_names)
    matching_classes.reject! { |c| c.to_s.start_with?("#<Class") || /[^:]*::[a-z]/.match?(c.to_s) || c.to_s.include?("ARGF") } ## weird few constants where :: is followed by a lowecase letter... it's not a class and I can't find anything written about it.
    RDL::Logging.log :heuristic, :trace, "Throwing out 'weird constants' leaves %d matching classes" % matching_classes.size
    ## TODO: special handling for arrays/hashes/generics?
    ## TODO: special handling for Rails models? see Bree's `active_record_match?` method
    #raise "No matching classes found for structural types with methods #{meth_names}." if matching_classes.empty?
    return if matching_classes.size > 10 ## in this case, just keep the struct types
    nom_sing_types = matching_classes.map { |c| if c.singleton_class? then RDL::Type::SingletonType.new(RDL::Util.singleton_class_to_class(c)) else RDL::Type::NominalType.new(c) end }
    RDL::Logging.log :heuristic, :trace, "These are: %s" % (nom_sing_types*", ")
    union = RDL::Type::UnionType.new(*nom_sing_types).canonical
    RDL::Logging.log :heuristic, :trace, "The union of which is canonicalized to %s" % union
    #struct_types.each { |st| var_type.ubounds.delete_if { |s, loc| s.equal?(st) } } ## remove struct types from upper bounds


    return union
    ## used to add and propagate here. Now that this is a heuristic, this should be done after running the rule.
    #var_type.add_and_propagate_upper_bound(union, nil)
  end


end

class << RDL::Heuristic
  attr_reader :rules
end

class String
  def is_rails_model?
    return false unless defined? Rails
    ActiveRecord::Base.descendants.map { |d| d.to_s }.include? self
  end

  def to_type
    camelized = self.camelize
    RDL::Type::NominalType.new(RDL::Util.to_class(camelized))
  end

  def is_pluralized_model?
    return false unless defined? Rails
    return false unless pluralize == self
    singularize.camelize.is_rails_model?
  end

  def model_set_type
    RDL::Globals.parser.scan_str "#T Array<#{singularize.camelize}> or ActiveRecord_Relation<#{singularize.camelize}>"
  end

end

if defined? Rails
  RDL::Heuristic.add(:is_model) { |var| if var.base_name.camelize.is_rails_model? then var.base_name.to_type end }
  RDL::Heuristic.add(:is_pluralized_model) { |var| if var.base_name.is_pluralized_model? then var.base_name.model_set_type end }
end

RDL::Heuristic.add(:struct_to_nominal) { |var| t1 = Time.now; g = RDL::Heuristic.struct_to_nominal(var); $stn = $stn + (Time.now - t1); g }
RDL::Heuristic.add(:int_names) { |var| if var.base_name.end_with?("id") || (var.base_name.end_with? "num") || (var.base_name.end_with? "count") then RDL::Globals.types[:integer] end }
RDL::Heuristic.add(:int_array_name) { |var| if var.base_name.end_with?("ids") || (var.base_name.end_with? "nums") || (var.base_name.end_with? "counts") then RDL::Globals.parser.scan_str "#T Array<Integer>" end }
RDL::Heuristic.add(:predicate_method) { |var| if var.base_name.end_with?("?") then RDL::Globals.types[:bool] end }
RDL::Heuristic.add(:string_name) { |var| if var.base_name.end_with?("name") then RDL::Globals.types[:string] end }
RDL::Heuristic.add(:hash_access) { |var|
  old_var = var
  var = var.type if old_var.is_a?(RDL::Type::OptionalType)
  types = []
  var.ubounds.reject { |t, ast| t.is_a?(RDL::Type::VarType) }.each { |t, ast|
    if t.is_a?(RDL::Type::IntersectionType)
      types = types + t.types
    else
      types << t
    end
  }
  if !types.empty? && types.all? { |t| t.is_a?(RDL::Type::StructuralType) && t.methods.all? { |meth, typ| ((meth == :[]) || (meth == :[]=)) && typ.args[0].is_a?(RDL::Type::SingletonType) && typ.args[0].val.is_a?(Symbol)  } }
    hash_typ = {}
    types.each { |struct|
      struct.methods.each { |meth, typ|
        if meth == :[]
          value_type = typ.ret#typ.ret.is_a?(RDL::Type::VarType) ? RDL::Typecheck.extract_var_sol(typ.ret, :arg).canonical : typ.ret.canonical
        elsif meth == :[]=
          value_type = typ.args[1]#typ.args[1].is_a?(RDL::Type::VarType) ? RDL::Typecheck.extract_var_sol(typ.args[1], :arg).canonical : typ.args[1].canonical
        else
          raise "Method should be one of :[] or :[]=, got #{meth}."
        end
        if value_type.is_a?(RDL::Type::UnionType)
          RDL::Type::UnionType.new(*value_type.types.map { |t| RDL::Typecheck.extract_var_sol(t, :arg) }).drop_vars.canonical
        elsif value_type.is_a?(RDL::Type::IntersectionType)
          RDL::Type::IntersectionType.new(*value_type.types.map { |t| RDL::Typecheck.extract_var_sol(t, :arg) }).drop_vars.canonical
        else
          value_type = RDL::Typecheck.extract_var_sol(value_type, :arg)
        end
        #value_type = value_type.drop_vars!.canonical if (value_type.is_a?(RDL::Type::UnionType) || value_type.is_a?(RDL::Type::IntersectionType)) && (!value_type.types.all? { |t| t.is_a?(RDL::Type::VarType) })
        hash_typ[typ.args[0].val] = RDL::Type::UnionType.new(value_type, hash_typ[typ.args[0].val]).canonical#RDL::Type::OptionalType.new(value_type) ## TODO:
      }
    }
    #var.ubounds.delete_if { |t| t.is_a?(RDL::Type::StructuralType) } #= [] ## might have to change this later, in particular to take advantage of comp types when performing solution extraction
    fht = RDL::Type::FiniteHashType.new(hash_typ, nil)
    if old_var.is_a?(RDL::Type::OptionalType)
      RDL::Type::OptionalType.new(fht)
    else
      fht
    end
  end
}


### For rules involving :include?, :==, :!=, etc. we would need to track the exact receiver/args used in the method call, and somehow store these in the bounds created for a var type.
