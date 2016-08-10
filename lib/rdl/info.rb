class RDL::Info
  # map from klass (String) to label (Symbol) to kind (Symbol) to either array or some other value
  #
  # class names are strings because they need to be manipulated in case they include ::
  #  (class names may have Util.add_singleton_marker applied to them to indicate they're singleton classes.)

  attr_accessor :info

  def initialize
    @info = Hash.new
  end

  # [+kind+] must map to an array
  def add(klass, label, kind, val)
    klass = klass.to_s
    label = label.to_sym
    @info[klass] = {} unless @info[klass]
    @info[klass][label] = {} unless @info[klass][label]
    @info[klass][label][kind] = [] unless @info[klass][label][kind]
    @info[klass][label][kind] << val
  end

  # if no prev info for kind, set to val and return true
  # if prev info for kind, return true if prev == val and false otherwise
  def set(klass, label, kind, val)
    klass = klass.to_s
    label = label.to_sym
    @info[klass] = {} unless @info[klass]
    @info[klass][label] = {} unless @info[klass][label]
    if @info[klass][label].has_key? kind
      return (val == @info[klass][label][kind])
    else
      @info[klass][label][kind] = val
      return true
    end
  end

  # replace info for kind
  def set!(klass, label, kind, val)
    klass = klass.to_s
    label = label.to_sym
    @info[klass] = {} unless @info[klass]
    @info[klass][label] = {} unless @info[klass][label]
    @info[klass][label][kind] = val
  end

  def has?(klass, label, kind)
    klass = klass.to_s
    label = label.to_sym
    return (@info.has_key? klass) &&
           (@info[klass].has_key? label) &&
           (@info[klass][label].has_key? kind)
  end

  def has_any?(klass, label, kinds)
    klass = klass.to_s
    label = label.to_sym
    return (@info.has_key? klass) &&
           (@info[klass].has_key? label) &&
           (kinds.any? { |k| @info[klass][label].has_key? k })
  end

  # eventually replace with Hash#dig
  def get(klass, label, kind)
    klass = klass.to_s
    label = label.to_sym
    t1 = @info[klass]
    return t1 if t1.nil?
    t2 = t1[label]
    return t2 if t2.nil?
    return t2[kind]
#    return @info[klass][label][kind]
  end

  def get_with_aliases(klass, label, kind)
    while $__rdl_aliases[klass] && $__rdl_aliases[klass][label]
      label = $__rdl_aliases[klass][label]
    end
    get(klass, label, kind)
  end

  def remove(klass, label, kind)
    klass = klass.to_s
    label = label.to_sym
    return unless @info.has_key? klass
    return unless @info[klass].has_key? label
    @info[klass][label].delete kind
  end

end
