class RDL::Switch
  @@switch = true
  def self.on?()
    @@switch
  end
  def self.on!()
    tmp = @@switch
    @@switch = true
    return tmp
  end
  def self.off!()
    tmp = @@switch
    @@switch = false
    return tmp
  end
  def self.set(state)
    tmp = @@switch
    @@switch = state
    return tmp
  end
  def self.off()
    return unless @@switch
    tmp = @@switch
    @@switch = false
    begin
      yield
    ensure
      @@switch = tmp
    end
  end
end

