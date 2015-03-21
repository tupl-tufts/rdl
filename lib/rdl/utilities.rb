module RDL
    
    # Recursion protection sentinel
    
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


    # Debug mode

    @@debug = true
    @@debug_channels = 0b00000001

    def self.debug?()
        @@debug
    end

    def self.debug_on()
        @@debug = true
    end

    def self.debug_off()
        @debug = false
    end

    def self.debug_channel_set(mask)
        @@debug_channels = mask
    end

    def self.debug(str, channel_num, opt=false) # Opt:true uses :p and Opt:false uses :puts
        !@@debug ||
            ((0b1 << (channel_num - 1)) & @@debug_channels)==0 ||
            (opt ? (p "RDL Debug Channel #{channel_num}:"; p str; p ""):(puts "RDL Debug Channel #{channel_num}: #{str}"))
    end # Returns true if failed, nil otherwise


    # Debug Channel Table of Contents
    # -------------------------------
    # 01 # Typesig method_ctc creation report
    # 02 # Typesig method_ctc debug
    # 03 # Typesig pre/post-cond debug
    # 04 # Typesig callpath
    # 05 #
    # 06 #
    # 07 #
    # 08 #
    # 09 #
    # 10 #
    # 11 #
    # 12 #
    # 13 #
    # 14 #
    # 15 #
    # 16 #
end

# RDL Check Stack for Recursion Management

class CheckStack < Array

    def push(obj)
        status = true
        self.each {|elem| if elem==obj then status = false; next true; end}
        status && super(obj)
    end

end
