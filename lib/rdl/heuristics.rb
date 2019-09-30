class RDL::Heuristic

  @rules = {}

  def self.add(name, &blk)
    raise RuntimeError, "Expected heuristic name to be Symbol, given #{name}." unless name.is_a? Symbol
    raise RuntimeError, "Expected block to be provided for heuristic." if blk.nil?    
    @rules[name] = blk
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
    is_rails_model?
  end

  def model_set_type
    RDL::Globals.parser.scan_str "#T Array<#{singularize}> or ActiveRecord_Relation<#{singularize}>"
  end
  
end


RDL::Heuristic.add(:is_model) { |var| if var.base_name.camelize.is_rails_model? then var.base_name.to_type end }
RDL::Heuristic.add(:is_pluralized_model) { |var| if var.base_name.is_pluralized_model? then var.base_name.model_set_type end }
RDL::Heuristic.add(:int_names) { |var| if var.base_name.end_with?("id") || (var.base_name == "num") || (var.base_name == "count") then RDL::Globals.types[:integer] end }
RDL::Heuristic.add(:int_array_name) { |var| if var.base_name.end_with?("ids") then RDL::Globals.parser.scan_str "#T Array<Integer>" end }
RDL::Heuristic.add(:predicate_method) { |var| if var.meth.to_s.end_with?("?") && var.category == :ret then RDL::Globals.types[:bool] end }
RDL::Heuristic.add(:hash_access) { |var|
  if !var.ubounds.empty? && var.ubounds.all? { |u| u.is_a?(RDL::Type::StructuralType) && u.methods.all? { |meth, typ| ((meth == :[]) || (meth == :[]=)) && typ.args.all? { |t| t.is_a?(RDL::Type::SingletonType) && t.val.is_a?(Symbol) } } }
    hash_typ = {}
    var.ubounds.each { |struct|
      struct.methods.each { |meth, typ|
        if meth == :[]
          hash_typ[typ.args[0].val] = typ.ret ## TODO: if ret is var type, should we extract solution first?
        elsif meth == :[]=
          hash_typ[typ.args[0].val] = hash_typ[typ.args[1]]
        else
          raise "Method should be one of :[] or :[]=, got #{meth}."
        end
      }
    }
    RDL::Type::FiniteHashType.new(hash_typ, nil)
  end
}


### For rules involving :include?, :==, :!=, etc. we would need to track the exact receiver/args used in the method call, and somehow store these in the bounds created for a var type.
