require 'stringio'

class RDL::Util

  SINGLETON_MARKER = "[s]"
  SINGLETON_MARKER_REGEXP = Regexp.escape(SINGLETON_MARKER)
  GLOBAL_NAME = "_Globals" # something that's not a valid class name

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

  def self.singleton_class_to_class(cls)
    cls_str = cls.to_s
    cls_str = cls_str.split('(')[0] + '>' if cls_str['(']
    to_class cls_str[8..-2]
  end

  def self.to_class_str(cls)
    cls_str = cls.to_s
    if cls_str.start_with? '#<Class:'
      cls_str = cls_str.split('(')[0] + '>' if cls_str['(']
      cls_str = RDL::Util.add_singleton_marker(cls_str[8..-2])
    end
    cls_str
  end

  def self.has_singleton_marker(klass)
    return (klass.to_s =~ /^#{SINGLETON_MARKER_REGEXP}/)
  end

  def self.remove_singleton_marker(klass)
    if klass.to_s =~ /^#{SINGLETON_MARKER_REGEXP}(.*)/
      return $1
    else
      return nil
    end
  end

  def self.each_leq_constraints(cons)
    cons.each_pair do |k, vs|
      vs.each do |v|
        if v[0] == :lower
          yield v[1], k
        else
          yield k, v[1]
        end
      end
    end
    nil
  end

  def self.puts_constraints(cons)
    each_leq_constraints(cons) { |a, b| puts "#{a} <= #{b}" }
  end

  def self.add_singleton_marker(klass)
    return SINGLETON_MARKER + klass
  end

  # Duplicate method...
  # Klass should be a string and may have a singleton marker
  # def self.pretty_name(klass, meth)
  #   if klass =~ /^#{SINGLETON_MARKER_REGEXP}(.*)/
  #     return "#{$1}.#{meth}"
  #   else
  #     return "#{klass}##{meth}"
  #   end
  # end

  def self.log_level_colors(a)
    colors = {
      trace: :yellow,
      debug: :green,
      debug_error: :red,
      info: :light_green,
      warning: :light_yellow,
      error: :light_red
    }
    colors[a]
  end

  def self.log_level_leq(a, b)
    levels = [:trace, :debug, :debug_error, :info, :warning, :error]

    levels.find_index(a) <= levels.find_index(b)
  end

  def self.log_str(area, level, message)
    tracing = RDL::Config.instance.log_levels[area] == :trace

    place = caller.find { |s| s.include?('lib/rdl') && !s.include?('block') && !s.include?('in `log') }
    place = place.match(/.*\/(.*?\.rb:[0-9]+)/)[1]

    lc = log_level_colors(level)

    depth_string = ''
    depth_string = " #{caller.length - 1}" if tracing
    leader = '[' + place.to_s.colorize(lc) + "#{depth_string}]"

    spacers = ''
    spacers = ' ' * ((caller.length - 1) / 2) if tracing

    spacers + leader + ' ' + message
  end

  def self.log_header(area, level, header)
    return unless log_level_leq(RDL::Config.instance.log_levels[area], level)

    stars = '***************'

    if RDL::Config.instance.log_levels[area] == :trace
      puts "#{log_str(area, level, header)} " + stars
    else
      puts stars + " #{log_str(area, level, header)} " + stars
    end

  end

  def self.log(area, level, message)
    return unless log_level_leq(RDL::Config.instance.log_levels[area], level)

    puts log_str(area, level, message)
  end

  def self.method_defined?(klass, method)
    begin
      sk = self.to_class klass
      msym = method.to_sym
    rescue NameError
      return false
    end

    return sk.methods.include?(:new) if method == :new

    sk.public_instance_methods(false).include?(msym) or
      sk.protected_instance_methods(false).include?(msym) or
      sk.private_instance_methods(false).include?(msym)
  end

  # Returns the @__rdl_type field of [+obj+]
  def self.rdl_type(obj)
    return (obj.instance_variable_defined?('@__rdl_type') && obj.instance_variable_get('@__rdl_type'))
  end

  def self.rdl_type_or_class(obj)
    return self.rdl_type(obj) || obj.class
  end

  def self.pp_klass_method(klass, meth)
    klass = klass.to_s
    if has_singleton_marker klass
      remove_singleton_marker(klass) + "." + meth.to_s
    else
      klass + "#" + meth.to_s
    end
  end

  def self.silent_warnings
    old_stderr = $stderr
    $stderr = StringIO.new
    yield
  ensure
    $stderr = old_stderr
  end
end
