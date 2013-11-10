module RDL
  module Gensym
    def self.gensym
      @gensym = 0 unless @gensym
      gsym = @gensym
      @gensym = gsym + 1
      gsym
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
      pre do |*args, &blk|
        p = Proxy.new
        p.instance_exec(*a, &b)
        # Allow for methods that only sometimes take DSL blocks.
        if blk
          new_blk = Proc.new do |*args|
            p.apply(self).instance_exec(*args, &blk)
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
    def initialize()
      @class = Class.new(BasicObject)
      @class.class_eval do
        include Kernel

        def initialize(obj)
          @obj = obj
        end

        def method_missing(mname, *args, &blk)
          raise "Attempt to call method #{mname} not in DSL"
        end
      end
    end

    def apply(obj)
      @class.new(obj)
    end

    def keyword(mname, *args, &blk)
      Keyword.new(@class, mname).instance_exec(*args, &blk)
    end

    def spec(mname, *args, &blk)
      @class.class_eval do
        define_method mname do |*args, &blk|
          @obj.__send__ mname, *args, &blk
        end
      end
      Spec.new(@class, mname).instance_exec(*args, &blk)
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
