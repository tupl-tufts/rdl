require 'set'
require 'require_all'
require_rel 'rdl/switch.rb'
require_rel 'rdl/types/*.rb'
require_rel 'rdl/contracts/*.rb'
require_rel 'rdl/wrap.rb'

# Hash from class name to method name to :pre/:post/:type to array of contracts
# class names are strings (because they need to be manipulated in case they include ::)
# method names are symbols
$__rdl_contracts = Hash.new

# Set of [class, method] pairs to wrap.
# class is a string
# method is a symbol
$__rdl_to_wrap = Set.new

# List of contracts that should be applied to the next method definition
$__rdl_deferred = []

module RDL

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
