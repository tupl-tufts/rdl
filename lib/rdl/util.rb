class RDL::Util
  def self.to_class(klass)
    return klass if klass.class == Class
    if has_singleton_marker(klass)
      klass = remove_singleton_marker(klass)
      sing = true
    end
    c = klass.to_s.split("::").inject(Object) { |base, name| base.const_get(name) }
    c = c.singleton_class if sing
    return c
  end

  def self.has_singleton_marker(klass)
    return (klass =~ /^\[singleton\]/)
  end
  
  def self.remove_singleton_marker(klass)
    if klass =~ /^\[singleton\](.*)/
      return $1
    else
      return nil
    end
  end

  def self.add_singleton_marker(klass)
    return "[singleton]" + klass
  end
    
  def self.method_defined?(klass, method)
    begin
      (self.to_class klass).method_defined? method.to_sym
    rescue NameError
      return false
    end
  end
end
