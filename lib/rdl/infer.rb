require 'rdl'

module RDL::Infer
  class Typ
    def superclass
      nil
    end

    def root?
      superclass.nil?
    end

    def <=(cls1)
      return true if self == cls1
      return false if root?
      return true if cls1.root?
      self.superclass <= cls1
    end

    def join(cls)
      return cls if self <= cls
      return self if cls <= self
      cls1 = self.superclass.join cls
      cls2 = self.join cls.superclass
      return cls2 if cls1 <= cls2
      return cls1 if cls2 <= cls1
    end
  end

  class Nominal < Typ
    attr_reader :cls

    def initialize(cls)
      @cls = cls
    end

    def to_s
      cls.to_s
    end

    def superclass
      cls.superclass.nil? ? nil : Nominal.new(cls.superclass)
    end

    def ==(cls1)
      cls1.class == Nominal and cls == cls1.cls
    end

    def <=(cls1)
      cls1.class == Nominal ? cls <= cls1.cls : (super cls1)
    end
  end

  class Arr < Typ
    attr_reader :base

    def initialize(base)
      @base = base.class <= Typ ? base : Nominal.new(base)
    end

    def to_s
      "Array[#{base}]"
    end

    def ==(cls1)
      cls1.class == Arr and base == cls1.base
    end

    def superclass
      base.root? ? Nominal.new(Array) : Arr.new(base.superclass)
    end
  end

  class Tup < Typ
    attr_reader :elts

    def initialize(elts)
      @elts = elts.map { |c| c.class <= Typ ? c : Nominal.new(c) }
    end

    def size
      @elts.length
    end

    def to_s
      "Tuple#{elts}"
    end

    def ==(cls1)
      cls1.class == Tup and size == cls1.size and
        elts.zip(cls1.elts).all? { |p| p[0] == p[1] }
    end

    def <=(cls1)
      if cls1.class == Tup and size == cls1.size
        elts.zip(cls1.elts).all? { |p| p[0] <= p[1] }
      else
        super cls1
      end
    end

    def superclass
      return Arr.new(Nominal.new(Object)) if elts.empty?
      if elts.all? { |p| p.root? }
        first = elts[0]
        return Arr.new(elts[1..-1].reduce(first) {|c1, c2| c1.join c2 })
      else
        Tup.new(elts.map { |p| p.root? ? p : p.superclass })
      end
    end

  end

  class Engine
    def initialize(cls, mname)
      @class = cls
      @mname = mname

      @arg_names = cls.instance_method(mname).parameters
      @args = {}
      @returns = []
    end

    def add_args(*a, &b)
      names = @arg_names
      block_handled = false
      names.each { |i|
        case i[0]
        when :req
          args(i[1], a.shift)
        when :rest
          args(i[1], a)
          # This isn't quite right yet, since this only works if all the
          # opts are at the end, but Ruby allows for more mixed args
          # (required args can appear after optional args and
          # take precedence).
        when :opt
          args(i[1], a.shift) unless a.empty?
        else nil
        end
      }
    end

    def add_return(ret)
      @returns.push ret
    end

    def do_infer
      as = @args
      ret = @returns

      { class: @class, mname: @mname,
        args: Hash[as.map { |n, al| [n, (infer_single_list al)]}],
        ret: (infer_single_list ret) }
    end

    private

    def infer_single(val)
      case val
      when Array
        Tup.new(val.map{ |v| infer_single v })
      else
        Nominal.new(val.class)
      end
    end

    def infer_single_list(lst)
      return Nominal.new(Object) if lst.empty?

      first = lst.shift
      first_type = infer_single(first)
      return first_type if lst.empty?
      rest_type = infer_single_list lst

      first_type.join rest_type
    end

    def args(aname, aval)
      @args[aname] = [] unless @args[aname]

      @args[aname].push aval
    end
  end

  def self.create_engine(cls, mname)
    @engines = [] unless @engines

    e = Engine.new(cls, mname)
    @engines.push(e)
    e
  end

  class << self
    attr_reader :engines
  end
end

class RDL::Spec
  def infer
    engine = RDL::Infer.create_engine(@class, @mname)
    pre_task { |*args, &blk| engine.add_args *args, &blk }
    post_task { |r, *a| engine.add_return r }
  end
end
