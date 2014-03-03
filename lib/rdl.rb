module RDL
  class Contract
    def apply(v); end
    def check(v); end
    def to_s; end
    def to_proc
      x = self
      Proc.new { |v| x.check v }
    end
  end

  class FlatCtc < Contract
    def initialize(s = "predicate", &p)
      raise "Expected predicate, got #{p}" unless p.arity.abs == 1
      @str = s.to_s; @pred = p
    end
    def apply(v)
      (check v) ? v : (raise "Value #{v} does not match contract #{self}")
    end
    def check(v)
      @pred.call v
    end
    def to_s; "#<FlatCtc:#{@str}>" end
  end

  def self.flat(&b)
    FlatCtc.new &b
  end

  def self.convert(v)
    case v
    when Contract
      v
    when Proc
      raise "Cannot convert non-unary proc #{p}" unless v.arity.abs == 1
      flat &v
    else
      FlatCtc.new(v) { |x| v === x }
    end
  end

  def self.not(c)
    raise "Expected flat contract, got #{c}" unless c.is_a? FlatCtc
    flat { |x| not (c.check x) }
  end

  module Gensym
    def self.gensym
      @gensym = 0 unless @gensym
      gsym = @gensym
      @gensym = gsym + 1
      gsym
    end
  end

  class Dsl
    attr_accessor :keywords, :specs

    def initialize(*a, &blk)
      instance_eval(*a, &blk) if block_given?
    end

    def keyword(mname, &blk)
      @keywords ||= {}
      raise "Keyword definition already exists for #{mname}" if @keywords[mname]
      @keywords[mname] = blk
    end

    def spec(mname, &blk)
      @specs ||= {}
      @specs[mname] ||= []
      @specs[mname].push(blk)
    end

    def self.extend(spec, &blk)
      raise "Expected a DSL spec, got #{spec}" unless spec.is_a?(Dsl)
      new_spec = Dsl.new
      old_keywords = spec.keywords
      if old_keywords
        new_spec.instance_variable_set(:@keywords, old_keywords.clone)
      end
      old_specs = spec.specs
      # FIXME: Probably need to do one more level down of cloning
      new_spec.instance_variable_set(:@specs, old_specs.clone) if old_specs
      new_spec.instance_eval(&blk) if block_given?
      new_spec
    end

    def apply(cls)
      if @keywords
        @keywords.each_pair do |m, b|
          if cls.method_defined? m
            raise "Method #{m} listed in spec already defined in #{cls}"
          end
          Keyword.new(cls, m).instance_eval(&b)
        end
      end
      if @specs
        @specs.each_pair do |m, bl|
          bl.each do |b|
            unless cls.method_defined? m
              raise "Method #{m} listed in spec not defined in #{cls}"
            end
            Spec.new(cls, m).instance_eval(&b)
          end
        end
      end
    end
  end

  class Spec
    def initialize(cls, mname)
      @class = cls
      @mname = mname

      unless cls.method_defined? mname
        raise "Method #{mname} not defined for #{cls}"
      end
    end

    def include_spec(blk, *args)
      unless blk.is_a?(Proc)
        raise "Expected a Proc, got #{blk.inspect}"
      end
      instance_exec(*args, &blk)
    end

    # Takes a block that transforms the incoming arguments
    # into (possibly) new arguments to be fed to the method.
    def pre(&b)
      mname = @mname
      old_mname = "__dsl_old_#{mname}_#{gensym}"
      pre_name = define_method_gensym("pre", &b)

      @class.class_eval do
        alias_method old_mname, mname

        define_method mname do |*args, &blk|
          results = self.__send__ pre_name, *args, &blk
          new_args = results[:args]
          new_blk = results[:block]
          self.__send__ old_mname, *new_args, &new_blk
        end
      end
    end

    # Takes a block that transforms the return value
    # into a (possibly) return value to be returned from the method.
    # The block also gets handed the original arguments.
    def post(&b)
      mname = @mname
      old_mname = "__dsl_old_#{mname}_#{gensym}"
      post_name = define_method_gensym("post", &b)

      @class.class_eval do
        alias_method old_mname, mname

        define_method mname do |*args, &blk|
          res = self.__send__ old_mname, *args, &blk
          self.__send__ post_name, res, *args, &blk
        end
      end
    end

    # Checks argument n (positional) against contract c.
    def arg(n, c)
      arg_name = define_method_gensym("arg") do |*args, &blk|
        raise "#{n+1} arguments expected, got #{args.length}" if args.length <= n
        args[n] = ctc.apply(args[n])
        { args: args, block: blk }
      end

      pre do |*args, &blk|
        self.__send__ arg_name, *args, &blk
      end
    end

    # Checks return value against contract c.
    def ret(c)
      ret_name = define_method_gensym("ret") do |r, *args, &blk|
        ctc.apply(r)
      end

      post do |r, *args, &blk|
        self.__send__ ret_name, r, *args, &blk
      end
    end

    # pre/post_task are versions of pre/post that ignore the
    # return value from the block and just pass along the
    # original arguments or return value.

    def pre_task(&b)
      pre_task_name = define_method_gensym("pre_task", &b)

      pre do |*args, &blk|
        self.__send__ pre_task_name, *args, &blk
        { args: args, block: blk }
      end
    end

    def post_task(&b)
      post_task_name = define_method_gensym("post_task", &b)

      post do |r, *args, &blk|
        self.__send__ post_task_name, r, *args, &blk
        r
      end
    end

    class PreConditionFailure < Exception; end
    class PostConditionFailure < Exception; end

    # pre/post_cond are like pre/post_task, except they check
    # the block return and error if the block returns false/nil.

    def pre_cond(desc = "", &b)
      pre_cond_name = define_method_gensym("pre_cond", &b)

      pre_task do |*args, &blk|
        raise PreConditionFailure, desc unless send pre_cond_name, *args, &blk
      end
    end

    def post_cond(desc = "", &b)
      post_cond_name = define_method_gensym("post_cond", &b)

      post_task do |r, *args, &blk|
        raise PostConditionFailure, desc unless send post_cond_name, r, *args, &blk
      end
    end

    # Since we're describing an existing method, not creating a new DSL,
    # here we want the dsl keyword to just intercept the block and add
    # our checks. We'll overwrite this functionality inside the entry version.
    def dsl(*a, &b)
      spec = Dsl.new *a, &b
      dsl_from spec
    end

    def dsl_from(spec, flags = {})
      p = Proxy.new flags[:warn]
      spec.specs.each_pair { |m, b| p.add_method m }
      spec.apply(p.instance_variable_get(:@class))
      pre do |*args, &blk|
        # Allow for methods that only sometimes take DSL blocks.
        if blk
          new_blk = Proc.new do |*args|
            unless self.is_a? RDL::Proxy
              obj = p.apply(self)
            else
              spec.specs.each_pair { |m, b| add_method m }
              spec.apply(class << self; self; end)
              obj = self
            end
            obj.instance_exec(*args, &blk)
          end
          { args: args, block: new_blk }
        else { args: args, block: blk }
        end
      end
    end

    private

    def define_method_gensym(desc="blk",&blk)
      blk_name = "__dsl_#{desc}_#{@mname}_#{gensym}"

      @class.class_eval do
        define_method blk_name, &blk
      end

      blk_name
    end

    def gensym
      RDL::Gensym.gensym
    end
  end

  class Keyword < Spec
    def initialize(cls, mname)
      if cls.method_defined? mname
        raise "Method #{mname} already defined for #{cls}"
      end

      @class = cls
      @mname = mname

      action { |*args| nil }
    end

    # For non-DSL keywords
    def action(&blk)
      mname = @mname

      @class.class_eval do
        define_method mname, &blk
      end
    end

    # For keywords that take the same DSL they are in.
    def dsl_rec
      action do |*args, &blk|
        instance_exec(*args, &blk)
        self
      end
    end

    # For keywords that take a different DSL than they are in.
    def dsl(cls = nil, *a, &b)
      mname = @mname

      raise "Need a class or block" unless cls or b

      unless b.nil?
        cls = Class.new(BasicObject) if cls.nil?
        cls.class_eval do include Kernel end
        Lang.new(cls).instance_exec(*a, &b)
      end

      action do |*args, &blk|
        c = cls.new(*a)
        c.instance_exec(*args, &blk)
        c
      end
    end
  end

  class Proxy
    def initialize(warn = false)
      @class = Class.new(BasicObject) do
        include Kernel

        def initialize(obj)
          @obj = obj
        end
      end

      if warn
        @class.class_eval do
          def method_missing(mname, *args, &blk)
            $stderr.puts "Attempt to call method #{mname} not in DSL at"
            caller.each { |s| $stderr.puts "  #{s}"}
            @obj.__send__ mname, *args, &blk
          end
        end
      else
        @class.class_eval do
          def method_missing(mname, *args, &blk)
            raise "Attempt to call method #{mname} not in DSL"
          end
        end
      end
    end

    def apply(obj)
      @methods.each do |m|
        unless obj.respond_to? m
          raise "Method #{m} not found in DSL object #{obj}"
        end
      end
      @class.new(obj)
    end

    def add_method(mname)
      @methods ||= []
      @methods.push(mname)
      @class.class_eval do
        define_method mname do |*args, &blk|
          @obj.__send__ mname, *args, &blk
        end
      end
    end
  end

  class Lang
    def initialize(cls)
      @class = cls
    end

    def keyword(mname, *args, &blk)
      Keyword.new(@class, mname).instance_exec(*args, &blk)
    end

    def spec(mname, *args, &blk)
      Spec.new(@class, mname).instance_exec(*args, &blk)
    end
  end

  def keyword(mname, *args, &blk)
    Lang.new(self).keyword(mname, *args, &blk)
  end

  alias :entry :keyword

  def spec(mname, *args, &blk)
    Lang.new(self).spec(mname, *args, &blk)
  end

  def self.create_spec(&b)
    Proc.new &b
  end

  def self.state
    @state = {} unless @state
    @state
  end
end
