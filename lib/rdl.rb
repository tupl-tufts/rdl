require_relative 'rdl/utilities'
require_relative 'rdl_ctc'
require_relative 'rdl_sig'
require_relative 'rdl_dsl'
require_relative 'rdl_rdc'


module RDL
    
    class << self
        attr_accessor :print_warning
    end

    # Syntactic sugar for creating new DSLs
    # See rdl_dsl.rb
    def dsl(*a, &blk)
        DSL.new(*a, &blk)
    end

    # Accessor for Array<Spec>
    def contracts
        @__rdlcontracts
    end

    # Get RDL type representation from String in format Superklass#klass or Superklass.klass
    def self.get_type(m)
        if m.include?('#')
            s = m.split('#')
            cls = eval(s[0])
            nt = RDL::Type::NominalType.new(cls)
        elsif m.include?('.')
            s = m.split('.')
            cls = eval(s[0])
            nt = eval("#{s[0]}.rdl_type")
        else
            raise Exception, "Argument to :get_type must be or the form \"Talks#list\" or \"Talks.list\""
        end

        m = s[1]
        nt.get_method(m.to_sym)
    end

    # Type parameters for defining typesigs
    def type_params(*t_params)
        return if t_params.empty?
    
        t_parameters = []
    
        iterators = {}
        t_params.each { |pair|
            t_parameters << pair[0]
            if pair.length == 1
                iterators[pair[0]] = nil
            else
                iterators[pair[0]] = pair[1]
            end
        }
    
        t_parameters.map! {|p| RDL::Type::VarType.new(p)}
        self.instance_variable_set :@__cls_params, iterators
    end

    # Typesig annotations for method types
    # See rdl_sig.rb
    def typesig(mname, sig, *metactc)
        RDL.debug "Module RDL::typesig called", 4
        
        cls = self
        if cls.class == Symbol
            cls = eval(cls.to_s)
            elsif cls.class == String
            cls = eval(cls)
        end
        
        cls.instance_eval do
            extend RDL if not cls.singleton_class.included_modules.include?(RDL)
            
            @__rdlcontracts ||= {}
            
            if self.instance_methods(true).include? mname
                @__rdlcontracts[mname] ||= Spec.new(self, mname.to_sym)
                @__rdlcontracts[mname].typesig sig, *metactc
            else
                RDL.debug "Typesig definition for :#{mname} deferred", 1
                deferred_specs = self.instance_variable_get(:@__deferred_specs)
                deferred_specs[mname] = [mname, sig, *metactc] if not deferred_specs.keys.include? mname
            end
            
        end
        
    end

    # Pre condition generator for use in :typesig annotations
    # See rdl_ctc.rb
    def pre(desc = "User Precondition", &blk)
        PreCtc.new(FlatCtc.new(desc,&blk))
    end

    # Post condition generator for use in :typesig annotations
    # See rdl_ctc.rb
    def post(desc = "User Postcondition", &blk)
        PostCtc.new(FlatCtc.new(desc,&blk))
    end

    # Provide subclasses with access to superclass rdl information
    # See rdl_sig.rb
    def self.extended(extendee)
        extendee.instance_variable_set(:@__deferred_specs, {})
        extendee.instance_variable_set(:@__cls_params, {})
        extendee.instance_variable_set(:@__typesigs, {})
    end

    # TODO needs updating
    # RDoc Generation tool
    # See rdl_rdc.rb
    def rdocTypesigFor(klass)
        tmp = RDLdocObj.new
        tmp.add_klass(klass)
        tmp.rdoc_gen
    end

end #End of Module:RDL



# RDL Recursion Protection

status = RDL.on?
RDL.turn_off if status

begin
    require_relative 'rdl/types'
    
    # stops RDL code from checking itself and eliminates
    # the old RTC NativeArray, NativeHash, etc.
    require_relative 'rdl/turn_off'
    RDL::TurnOffCheck.turn_off_check
ensure
    RDL.turn_on if status
end
