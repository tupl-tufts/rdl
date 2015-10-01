require 'singleton'

class RDL::Config
  include Singleton

  attr_accessor :nowrap
  attr_accessor :gather_stats
  
  def initialize
    @nowrap = Set.new
    @gather_stats = true
  end

  def add_nowrap(*klasses)
    klasses.each { |klass| @nowrap.add klass }
  end

  def remove_nowrap(*klasses)
    klasses.each { |klass| @nowrap.delete klass }
  end
  
  def profile_stats(outname="/#{__FILE__[0...-3]}",outdir="")
    require 'profile'
    Profiler__.stop_profile # Leave setup out of stats
    
    at_exit do
      Profiler__.stop_profile
      $__rdl_contract_switch.off {
        totals = {}
        Profiler__.class_variable_get(:@@maps).values.each do |threadmap|
          threadmap.each do |key, data|
            total_data = (totals[key.to_s] ||= [-1, 0, 0.0, 0.0, key])
            total_data[1] += data[0]
            total_data[2] += data[1]
            total_data[3] += data[2]
          end
        end
        $__rdl_wrapped_calls.each{ |mname,ct|
          if (totals[mname]) then totals[mname][0] = ct end
        }
        
        require 'json'
        fpath = "#{outdir}/#{outname}_rdlstat.json".gsub("//","")
        File.open(fpath,'w') do |file|
          file.puts totals.to_json
        end
      }
    end
    
    Profiler__.start_profile # Restart profiler after setup
  end
end