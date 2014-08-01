module RDL
  @@master_switch = true
  def self.on?()
    @@master_switch 
  end
  def self.turn_on(); @@master_switch = true end
  def self.turn_off(); @@master_switch = false end
  def self.set_to(state); @@master_switch = state end
  def self.ensure_off()
    state = @state
    @@master_switch = false
    state
  end
end

