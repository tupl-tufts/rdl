# Defines RDL methods that do nothing

module RDL
  def nowrap(*args); end
  def at(*args); end
  def do_typecheck(*args); end
  def note_type(*args); end
  def remove_type(*args); end
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
  def type_alias(*args); end

end

module RDL
  extend RDL::Annotate
end

def RDL.config(*args); end

class Object
  def rdl_instantaite!(*args); self; end
  def rdl_deinstantaite!(*args); self; end
  def rdl_type_cast(*args); self; end
end
