# Defines RDL methods that do nothing

module RDL
end

module RDL::Annotate
  def pre(*args); end
  def post(*args); end
  def type(*args); end
  def var_type(*args); end
  def attr_accessor_type(*args)
    args.each_slice(2) { |name, typ| attr_accessor name }
    nil
  end

  def attr_reader_type(*args)
    args.each_slice(2) { |name, typ| attr_reader name }
    nil
  end

  alias_method :attr_type, :attr_reader_type

  def attr_writer_type(*args)
    args.each_slice(2) { |name, typ| attr_writer name }
    nil
  end

  def rdl_alias(*args); end
  def type_params(*args); end
end

module RDL::RDLAnnotate
  define_method :rdl_pre, RDL::Annotate.instance_method(:pre)
  define_method :rdl_post, RDL::Annotate.instance_method(:post)
  define_method :rdl_type, RDL::Annotate.instance_method(:type)
  define_method :rdl_var_type, RDL::Annotate.instance_method(:var_type)
  define_method :rdl_alias, RDL::Annotate.instance_method(:rdl_alias)
  define_method :rdl_type_params, RDL::Annotate.instance_method(:type_params)
  define_method :rdl_attr_accessor_type, RDL::Annotate.instance_method(:attr_accessor_type) # note in disable these don't call var_type
  define_method :rdl_attr_reader_type, RDL::Annotate.instance_method(:attr_reader_type)
  define_method :rdl_attr_type, RDL::Annotate.instance_method(:attr_type)
  define_method :rdl_attr_writer_type, RDL::Annotate.instance_method(:attr_writer_type)
end


module RDL
  extend RDL::Annotate
  def self.type_alias(*args); end
  def self.nowrap(*args); end
  def self.do_typecheck(*args); end
  def self.at(*args); end
  def self.note_type(*args); end
  def self.remove_type(*args); end
  def self.instantiate!(*args); self; end
  def self.deinstantiate!(*args); self; end
  def self.type_cast(*args); self; end
  def self.query(*args); end
end

def RDL.config(*args); end
