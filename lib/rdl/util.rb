class RDL::Util
  def self.to_class(s)
    return s if s.class == Class
    return s.to_s.split("::").inject(Object) { |base, name| base.const_get(name) }
  end

  def self.method_defined?(klass, method)
    begin
      (self.to_class klass).method_defined? method.to_sym
    rescue NameError
      return false
    end
  end
end
