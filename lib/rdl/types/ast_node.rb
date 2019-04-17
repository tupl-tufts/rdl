require 'pp'

module RDL::Type
  class AstNode < Type
    attr_reader :op
    attr_accessor  :val, :children, :parent

    def initialize(op, val)
      @op = op
      @val = val
      @children = []
      @parent = nil
    end

    def root
      unless self.parent
        self
      else
        root(self.parent)
      end
    end

    def insert(child)
      raise "AstNode expected" unless child.is_a? AstNode
      @children << child
    end

    def find_all(op)
      @children.find_all { |obj| obj.op == op }
    end

    def find_one(op)
      results = self.find_all(op)
      raise "One node expected" unless results.size < 2
      results[0]
    end

    def ==(other)
      return false if other.nil?
      other = other.canonical
      return (other.instance_of? self.class) && (other.val.equal? @val)
    end

    alias eql? ==

    def match(other)
      other = other.canonical
      other = other.type if other.instance_of? AnnotatedArgType
      return true if other.instance_of? WildQuery
      return self == other
    end

    def hash # :nodoc:
      return @val.hash
    end

    def to_s
      self.pretty_inspect
    end

    def <=(other)
      return Type.leq(self, other)
    end

    def member?(obj, *args)
      raise "member? on AstNode called"
    end

    def instantiate(inst)
      return self
    end
  end
end
