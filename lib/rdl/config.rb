require 'singleton'

class RDL::Config
  include Singleton

  attr_accessor :nowrap
  attr_accessor :gather_stats, :at_exit_installed
  attr_accessor :report, :get_types, :guess_types
  attr_accessor :weak_update_promote, :widen_bound, :promote_widen, :use_comp_types, :check_comp_types
  attr_accessor :type_defaults, :infer_defaults, :pre_defaults, :post_defaults, :rerun_comp_types, :assume_dyn_type
  attr_accessor :use_precise_string, :number_mode, :use_unknown_types, :infer_empties
  attr_accessor :convert_type_errors_to_dyn_type, :log_levels

  def initialize
    RDL::Config.reset(self)
  end

  def self.reset(c=RDL::Config.instance)
    c.nowrap = Set.new # Set of symbols
    c.gather_stats = false
    c.report = false # if this is enabled by default, modify @at_exit_installed
    c.guess_types = [] # same as above
    c.get_types = [] # Array<Array<[String, Symbol>>: list of class/method name pairs to collect type data for
    c.at_exit_installed = false
    c.weak_update_promote = false
    c.promote_widen = false
    c.type_defaults = { wrap: true, typecheck: false}
    c.infer_defaults = { time: nil }
    c.pre_defaults = { wrap: true }
    c.post_defaults = { wrap: true }
    c.assume_dyn_type = false
    c.widen_bound = 5
    c.use_comp_types = true
    c.check_comp_types = false ## this for dynamically checking that the result of a computed type still holds
    c.rerun_comp_types = false ## this is for dynamically checking that a type computation still evaluates to the same thing as it did at type checking time
    c.use_precise_string = false
    c.number_mode = false
    c.use_unknown_types = false
    c.infer_empties = true ## if [] and {} should be typed as Array<var> and Hash<var, var>
    c.convert_type_errors_to_dyn_type = false
    c.log_levels = {
      typecheck: :warn,
      inference: :warn
    }
  end

  def add_nowrap(*klasses)
    klasses.each { |klass|
      @nowrap.add klass.to_s.to_sym
      @nowrap.add RDL::Util.add_singleton_marker(klass.to_s).to_sym
    }
  end

  def remove_nowrap(*klasses)
    klasses.each { |klass|
      @nowrap.delete klass.to_s.to_sym
      @nowrap.delete RDL::Util.add_singleton_marker(klass.to_s).to_sym
    }
  end

  # To use, copy these 3 lines to the test file of a gem
=begin
require_relative '../rdl3/rdl/lib/rdl.rb'
require_relative '../rdl3/rdl/lib/rdl_types.rb'
RDL::Config.instance.profile_stats
=end
  def profile_stats(outname="/#{__FILE__[0...-3]}",outdir="")
    require 'profile'
    Profiler__.stop_profile # Leave setup out of stats

    at_exit do
      Profiler__.stop_profile
      RDL::Globals.contract_switch.off {
        puts "START."
        puts "Performing Profile Analysis"
        # Class Name => [Times Contract Called | Times Called | Time | Time | Class Profile]
        # Implications:
        #   [nil] -> Method exists in object space, but not used
        #   [-1] -> Contract exists for method, but method not profiled
        #   [-1, ...] -> Method profiled, but no contract exists
        totals = {}

        puts "Retrieving Profiler Data"
        Profiler__.class_variable_get(:@@maps).values.each do |threadmap|
          threadmap.each do |key, data|
            total_data = (totals[key.to_s] ||= [-1, 0, 0.0, 0.0, key])
            total_data[1] += data[0]
            total_data[2] += data[1]
            total_data[3] += data[2]
          end
        end

        puts "Scanning Object Space"
        kls = []
        ObjectSpace.each_object { |obj|
          if kls.include? obj.class then
            next
          end
          kls << obj.class
          mthds = obj.public_methods(false) + obj.private_methods(false) + obj.protected_methods(false)
          puts "Class #{obj.class}"
          mthds.each{ |mthd|
            puts "    :#{mthd}"
            totals["#{obj.class}::#{mthd.to_s}".gsub('::','#')] ||= [nil] unless mthd.to_s =~ /new/
          }
        }

        p "Scanning RDL Contract Log"
        RDL::Globals.wrapped_calls.each{ |mname,ct|
          if (totals[mname]) then
            if (totals[mname][0]) then
              totals[mname][0] = ct
            else
              totals[mname][0] = -1
            end
          end
        }

        puts "Analyzing Statistics"
        filtered = {}
        totals.each{ |k,v|
          if (not (k=~/(rdl)|(RDL)/)) and (v[0].nil? or v[0]==-1) then filtered[k]=v end
        }

        puts "Writing Output"
        require 'json'
        fpath = "#{outdir}/#{outname}_rdlstat.json".gsub('//','')
        File.open(fpath,'w') do |file|
          file.puts "POTENTIAL PROBLEMS"
          filtered.each{ |k,v|
            begin
              k =~ /((?:.+\#)*)(.+)/
              x = $1[0...-1] # Store $1 and $2 before overriden
              y = $2
              if (x =~ /\<Class\:/) then
                puts "Cannot evaluate user-defined class #{x}"
              else
                kls = eval x.gsub('#','::')
                mthds = kls.public_methods(false) + kls.protected_methods(false) # Ignoring private methods
                if (mthds.include? y.to_sym)
                  file.printf "%-20s %-s", k, v.to_s
                  file.puts ""
                else
                  puts "Ignoring inheritance problem for #{k}"
                end
              end
            rescue
            end
          }
          file.puts " "
          file.puts "JSON OBJECT"
          file.puts totals.to_json
        end
        puts "DONE."
      }
    end

    Profiler__.start_profile # Restart profiler after setup
  end

  def do_report
    return unless @report
    puts "------------------------------"
    typechecked = []
    missing = []
    RDL::Globals.info.info.each_pair { |klass, meths|
      meths.each { |meth, kinds|
        if kinds[:typecheck]
          if kinds[:typechecked]
            typechecked << [klass, meth]
          else
            missing << [klass, meth]
          end
        elsif kinds[:typechecked]
          raise RuntimeError, "#{RDL::Util.pp_klass_method(klass, meth)} typechecked but not annotated to do so?!"
        end
      }
    }
    unless typechecked.empty?
      puts "TYPECHECKED METHODS:"
      typechecked.each { |klass, meth| puts RDL::Util.pp_klass_method(klass, meth) }
    end
    unless missing.empty?
      puts unless typechecked.empty?
      puts "METHODS ANNOTATED TO BE TYPECHECKED BUT NOT TYPECHECKED:"
      missing.each { |klass, meth| puts RDL::Util.pp_klass_method(klass, meth) }
    end
  end

  def do_get_meth_type(klass, meth, the_meth)
    puts "GETTING METH TYPE FOR #{klass} AND #{meth}"
    params = the_meth.parameters
    param_types = params.keep_if { |p| p.size == 2 }.to_h
    param_names = []
    params.each_with_index { |param, i|
      _, name = param
      ## TODO: Differentiate based on kind here?
      ## TODO: Anything with block here?
      param_names << name if name
    }
    otypes = RDL::Globals.info.get(klass, meth, :otype) if RDL::Globals.info.has?(klass, meth, :otype) # observed types
    return if otypes.nil?
    #otargs = []
    otargs = {}
    otret = RDL::Globals.types[:bot]
    otblock = false
    binding_meth_name = "RDL_#{klass}_#{(meth.hash + meth.to_s.hash).abs}".gsub("::", "__").gsub("[s]", "singleton_")
    otypes.each { |ot|
      binds_hash = RDL.send(binding_meth_name, *ot[:args])
      binds_hash.each { |param_name, typ|
        if param_types[param_name] == :rest
          raise "Expected Array of classes, got #{typ}" unless typ.is_a?(Array)
          new_typ = RDL::Type::UnionType.new(*typ).canonical
        else
          new_typ = typ.is_a?(RDL::Type::Type) ? typ : RDL::Wrap.val_to_type(typ) ## may not be a Type for default arguments
        end
        otargs[param_name] = otargs[param_name] ? RDL::Type::UnionType.new(otargs[param_name], new_typ).canonical : new_typ
      }
      otret = RDL::Type::UnionType.new(otret, ot[:ret]).canonical if defined? otret
      otblock = otblock || ot[:block]
    }
    require 'method_source'
    otargs.each { |param, typ| if param_types[param] == :rest then otargs[param] = RDL::Type::VarargType.new(typ) end }
    printed_args = ""
    otargs.each { |param, typ| printed_args << "#{param} => #{typ}\n" }
    #otargs.transform_values { |v| v.to_s }.to_s
    CSV.open("#{File.basename(Dir.getwd)}_observed_types.csv", "a+") { |csv|
      csv << [klass.to_s, meth.to_s, param_names.join(", "), printed_args, otret.to_s, the_meth.source, the_meth.comment]
    }

  end


  def guess_meth(klass, meth, is_sing, the_meth)
    # first print based on signature according to Ruby
    first = true
    block = false
    print "  type #{if is_sing then '\'self.' + meth + '\'' else ':' + meth end}, '("
    params = the_meth.parameters
    params.each_with_index { |param, i|
      kind, name = param
      print ", " unless first || kind == :block
      case kind
      when :req
        print "XXXX #{name}"
      when :opt
        print "?XXXX #{name}"
      when :rest
        print "*#XXXX #{name}"
      when :key
        print "#{name}: XXXX"
      when :block
        block = true
      else
        print "???? param of kind #{kind} for #{name}"
      end
      first = false
    }
    print ")"
    print " { BLOCK }" if block
    puts " -> XXXX'"

    # next print based on observed types
    otypes = RDL::Globals.info.get(klass, meth, :otype) if RDL::Globals.info.has?(klass, meth, :otype) # observed types
    return if otypes.nil?
    first = true
    print "  type #{if is_sing then '\'self.' + meth + '\'' else ':' + meth end}, '("
    otargs = []
    otret = RDL::Globals.types[:bot]
    otblock = false
    otypes.each { |ot|
      ot[:args].each_with_index { |t, i|
        otargs[i] = RDL::Globals.types[:bot] if otargs[i].nil?
        begin
          otargs[i] = RDL::Type::UnionType.new(otargs[i], t).canonical
        rescue NameError; end
      }
      otret = RDL::Type::UnionType.new(otret, RDL::Type::NominalType.new(ot[:ret])).canonical if defined? otret
      otblock = otblock || ot[:block]
    }
    otargs.each { |t|
      print ", " unless first
      print t
      first = false
    }
    print ")"
    print " { BLOCK }" if otblock
    puts " -> #{otret}'"
  end

  def do_guess_types
    return if @guess_types.empty?
    puts "------------------------------"
    puts "TYPE GUESSES"
    RDL::Config.instance.guess_types.each { |klass|
      puts
      puts "class #{klass}"
      the_klass = RDL::Util.to_class(klass)
      sklass = RDL::Util.add_singleton_marker(klass.to_s)
      the_klass.singleton_methods(false).each { |meth|
        next unless meth.to_s =~ /^__rdl_(.*)_old/
        guess_meth(sklass, $1, true, the_klass.singleton_method(meth))
      }
      the_klass.instance_methods(false).each { |meth|
        next unless meth.to_s =~ /^__rdl_(.*)_old/
        guess_meth(klass, $1, false, the_klass.instance_method(meth))
      }
      puts "end"
    }
  end


  def do_get_types
    return if @get_types.empty?
    require 'csv'

    CSV.open("#{File.basename(Dir.getwd)}_observed_types.csv", "wb") { |csv|
      csv << ["Class", "Method", "Parameter Names", "Observed Arg Types", "Observed Return Type", "Source Code", "Comments"]
    }

    RDL::Config.instance.get_types.each { |klass, meth|
      # the_klass = RDL::Util.to_class(klass)
      # sklass = RDL::Util.add_singleton_marker(klass.to_s)
      wrapped_name = RDL::Wrap.wrapped_name(klass, meth)
      begin
        the_meth = RDL::Util.to_class(klass).instance_method(wrapped_name)
        do_get_meth_type(klass, meth, the_meth)
      rescue NameError; end
    }
  end
end


private

  def install_at_exit
    return if @at_exit_installed
    at_exit do
      RDL::Config.instance.do_report
      RDL::Config.instance.do_guess_types
      RDL::Config.instance.do_get_types
    end
    @at_exit_installed = true
  end
