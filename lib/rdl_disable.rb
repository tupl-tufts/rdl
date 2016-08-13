# Defines RDL methods that do nothing

module RDL; end

def RDL.config(*args); end

class Object
  def pre(*args); end
  def post(*args); end
  def type(*args); end
  def var_type(*args); end
  def rdl_alias(*args); end
  def type_params(*args); end
  def rdl_nowrap(*args); end
  def instantaite!(*args); self; end
  def deinstantaite!(*args); self; end
  def type_cast(*args); self; end
  def type_alias(*args); end
  def rdl_do_typecheck(*args); end
  def rdl_note_type(*args); end
  def rdl_remove_type(*args); end

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
end
