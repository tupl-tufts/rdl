class RDL::RefinementSet
  @@refinement_connections = {}
  @@refinements = {}

  def self.using(ref, refinement_module)
    (@@refinement_connections[ref.to_s] ||= [])<< refinement_module
  end

  def self.usings_modules(ref)
    @@refinement_connections[ref]
  end

  def self.add(ref, klass, meth, processed_type)
    klass = klass.to_s
    @@refinements[ref] ||= {}
    @@refinements[ref][klass] ||= {}
    @@refinements[ref][klass][meth] ||= []
    @@refinements[ref][klass][meth]<< processed_type
  end

  def self.get(ref, klass, name)
    @@refinements.fetch(ref, {}).fetch(klass, {}).fetch(name, nil)
  end
end
