require 'ruby-state-machine/state_machine'

module StateMachine
  module ClassMethods
    extend RDL

    def __dsl_state_valid?(s)
      s.keys.include?(:state) and (@machine.states.include?(s[:state]) or s[:state] == :stay)
    end

    def __dsl_next_valid?(t)
      n = t[:next]

      if n.class == Hash
        (not t.keys.include?(:decider)) and __dsl_state_valid?(n)
      elsif n.class == Array
        t.keys.include?(:decider) and t[:next].all? {|i|
          __dsl_state_valid?(i)
        }
      else
        @machine.states.include?(n) or n == :stay
      end
    end

    spec :state_transition do
      pre_cond "state_transition has invalid args" do |t|
        state_ok = (t.keys.include?(:state) and @machine.states.include?(t[:state]))
        event_ok = (t.keys.include?(:event) and @machine.events.include?(t[:event]))

        if t.keys.include?(:next)
          next_ok = __dsl_next_valid?(t)
        else
          next_ok = false
        end

        state_ok and event_ok and next_ok
      end
    end
  end
end
