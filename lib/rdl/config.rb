require 'singleton'

class RDL::Config
  include Singleton

  attr_accessor :nowrap
  attr_accessor :gather_stats
  attr_accessor :report

  def initialize
    @nowrap = Set.new
    @gather_stats = false
    @report = false
  end

  def add_nowrap(*klasses)
    klasses.each { |klass| @nowrap.add klass }
  end

  def remove_nowrap(*klasses)
    klasses.each { |klass| @nowrap.delete klass }
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
      $__rdl_contract_switch.off {
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
        $__rdl_wrapped_calls.each{ |mname,ct|
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
end

at_exit do
  if RDL::Config.instance.report
    typechecked = []
    missing = []
    $__rdl_info.info.each_pair { |klass, meths|
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
end
