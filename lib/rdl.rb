require_relative 'rdl/master_switch'
require 'set'
require_relative 'rdl_ctc'
require_relative 'rdl_sig'
require_relative 'rdl_dsl'
require_relative 'rdl_rdc'


module RDL
    
    class << self
        attr_accessor :print_warning
    end

    # Get RDL type representation from String in format Superklass#klass or Superklass.klass
    # TODO double check this description
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
            raise Exception, "argument to get_type must be or the form \"Talks#list\" or \"Talks.list\""
        end

        m = s[1]
        nt.get_method(m.to_sym)
    end

    # Create new keyword for dsl
    def keyword(mname, *args, &blk)
        Lang.new(self).keyword(mname, *args, &blk)
    end

    alias :entry :keyword

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

    # Create Spec for method
    def spec(mname, *args, &blk)
        mname = mname.to_sym
        RDL.debug "spec called", 4
        if self.instance_methods(true).include? mname
            RDL.debug "spec truecase", 4
            Lang.new(self).spec(mname, *args, &blk)
        else
            RDL.debug "spec for :#{mname} falsecase #{self.instance_methods(false)}", 5
            deferred_specs = self.instance_variable_get(:@__deferred_specs)
            deferred_specs[mname] = [] if not deferred_specs.keys.include? mname
            deferred_specs[mname].push([args, blk])
        end
    end

    # Typesig annotations for method types
    def typesig(mname, sig, *metactc)
        RDL.debug "module RDL::typesig called", 4
        Object.new.typesig(self, mname, sig, *metactc)
    end

    # Pre condition generator for use in :typesig annotations
    def pre(desc = "User Precondition", &blk)
        PreCtc.new(FlatCtc.new(desc,&blk))
    end

    # Post condition generator for use in :typesig annotations
    def post(desc = "User Postcondition", &blk)
        PostCtc.new(FlatCtc.new(desc,&blk))
    end

    # Shortcut to create Proc
    def self.create_spec(&b)
        Proc.new &b
    end

    # TODO Desc
    def self.state
        @state = {} unless @state
        @state
    end

    # TODO desc
    def self.extended(extendee)
        extendee.instance_variable_set(:@__deferred_specs, {})
        extendee.instance_variable_set(:@__cls_params, {})
        extendee.instance_variable_set(:@__typesigs, {})
    end

    # TODO needs updating; see rdl_rdc.rb
    def rdocTypesigFor(klass)
        tmp = RDLdocObj.new
        tmp.add_klass(klass)
        tmp.rdoc_gen
    end

end #End of Module:RDL


class Object
    
    # Typesig declaration handler
    # TODO write test case for typesig before declaration; see test_typesig.rb
    def self.method_added(mname)
        specs = self.instance_variable_get :@__deferred_specs
    
        if specs and specs.keys.include? mname
            sm = specs[mname]
            specs.delete mname
            sm.each {|args, blk| self.spec(mname, *args, &blk)}
        end
    end

    # Handles internal typesig routing; See rdl_sig.rb
    def typesig(cls, mname, sig, *metactc)
        RDL.debug "Object::typesig called", 4
        
        if cls.class == Symbol
            cls = eval(cls.to_s)
            elsif cls.class == String
            cls = eval(cls)
        end
        
        cls.instance_eval do
            extend RDL if not cls.singleton_class.included_modules.include?(RDL)
            
            spec mname.to_sym do
                typesig sig, *metactc
            end
        end
        
        RDL.debug "Object::typesig finished\n", 4
    end
    
    # TODO implement this; see rdl_rdc.rb
    def rdocTypesigFor(klass)
        
    end
end

# TODO update this with RDL Master Switch fix
# TODO clean up following code
status = RDL.on?
RDL.turn_off if status

begin
    require_relative 'rdl/types'
    # require_relative '../types/ruby-2.1/core/array.rb'
    
    # stops RDL code from checking itself and eliminates
    # the old RTC NativeArray, NativeHash, etc.
    require_relative 'rdl/turn_off'
    RDL::TurnOffCheck.turn_off_check
    ensure
    RDL.turn_on if status
end

#RDL.print_warning = false
