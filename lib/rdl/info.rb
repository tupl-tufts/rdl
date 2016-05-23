class RDL::Info
  # map from klass (String) to meth (Symbol) to kind (Symbol) to either array or some other value
  #
  # class names are strings because they need to be manipulated in case they include ::
  #  (class names may have Util.add_singleton_marker applied to them to indicate they're singleton classes.)

  attr_accessor :info

  def initialize
    @info = Hash.new
  end

  # [+kind+] must map to an array
  def add(klass, meth, kind, val)
    klass = klass.to_s
    meth = meth.to_sym
    @info[klass] = {} unless @info[klass]
    @info[klass][meth] = {} unless @info[klass][meth]
    @info[klass][meth][kind] = [] unless @info[klass][meth][kind]
    @info[klass][meth][kind] << val
  end

  # replace info for kind
  def set(klass, meth, kind, val)
    klass = klass.to_s
    meth = meth.to_sym
    @info[klass] = {} unless @info[klass]
    @info[klass][meth] = {} unless @info[klass][meth]
    @info[klass][meth][kind] = val
  end

  def has?(klass, meth, kind)
    klass = klass.to_s
    meth = meth.to_sym
    return (@info.has_key? klass) &&
           (@info[klass].has_key? meth) &&
           (@info[klass][meth].has_key? kind)
  end

  def has_any?(klass, meth, kinds)
    klass = klass.to_s
    meth = meth.to_sym
    return (@info.has_key? klass) &&
           (@info[klass].has_key? meth) &&
           (kinds.any? { |k| @info[klass][meth].has_key? k })
  end

  def get(klass, meth, kind)
    klass = klass.to_s
    meth = meth.to_sym
    return @info[klass][meth][kind]
  end
end
