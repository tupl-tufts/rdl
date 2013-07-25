require 'rdl'

class RDL::Spec
  def inspect(*events, &blk)
    trace = TracePoint.new(*events, &blk)
    pre_task { |*args| trace.enable }
    post_task { |*args| trace.disable }
  end
end
