module RDL
  class MasterSwitch
    @@master_switch = true
    def self.is_on?(); return @@master_switch end
    def self.turn_on(); @@master_switch = true end
    def self.turn_off(); @@master_switch = false end
    def self.set_to(state); @@master_switch = state end
    def self.ensure_off()
      state = @state
      @@master_switch = false
      state
    end
  end
  
  def self.turn_switch_on(); MasterSwitch.turn_on() end
  def self.turn_switch_off(); MasterSwitch.turn_off() end
  def self.is_switch_on?(); MasterSwitch.is_on?() end
  def self.set_switch_to(state); MasterSwitch.set_to(state) end
end
