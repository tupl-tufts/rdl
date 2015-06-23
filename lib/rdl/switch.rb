class RDL::Switch
  def initialize
    @switch = true
  end
  def off?()
    return not(@switch)
  end
  def off()
    return unless @switch
    tmp = @switch
    @switch = false
    begin
      ret = yield
    ensure
      @switch = tmp
    end
    return ret
  end
end

