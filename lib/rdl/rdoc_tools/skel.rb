def skel(klass)
  ret = ""
  
  if klass.instance_of? Class then
    ret << "class #{klass}"
    ret << "< #{klass.superclass}" if klass.superclass != Object
  elsif klass.instance_of? Module then
    ret << "module #{klass}"
  end
  ret << "\n"
  ret << "  extend RDL\n"
  klass.methods(false).each do |m|
    ret << "  CLASS METHOD: typesig(:#{m})\n"
  end
  klass.instance_methods(false).each do |m|
    ps = (klass.instance_method m).parameters
    ret << "  typesig(:#{m}, \"("
    first = true
    block = false
    ps.each { |kind, name|
        name = "XXXX" unless name
        if kind == :req then
          ret << ", " unless first
          first = false
          ret << "#{name} : XXXX"
        elsif kind == :opt then
          ret << ", " unless first
          first = false
          ret << "#{name} : ?XXXX"
        elsif kind == :args or kind == :rest then
          ret << ", " unless first
          first = false
          ret << "#{name} : *XXXX"
        elsif kind == :block then
          block = true
        else
          puts "ERROR! Don't know what #{kind}, #{name} means"
        end
    }
    if block then
      ret << ") { BLOCK }\")\n"
    else
      ret << ")\")\n"
    end
  end
  ret << "end\n"
end

require "set"

puts skel(Set)
