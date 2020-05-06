
class RDL::Logging

  def self.log_level_colors(a)
    colors = {
      trace: :yellow,
      debug: :green,
      debug_error: :red,
      info: :light_green,
      warning: :light_yellow,
      error: :light_red
    }
    colors[a]
  end

  def self.log_level_leq(a, b)
    levels = [:trace, :debug, :debug_error, :info, :warning, :error]

    levels.find_index(a) <= levels.find_index(b)
  end

  def self.log_str(area, level, message)
    tracing = RDL::Config.instance.log_levels[area] == :trace

    place = caller.find { |s| s.include?('lib/rdl') && !s.include?('in `log') }
    file_line = place.match(/.*\/(.*?\.rb:[0-9]+)/)[1]
    meth = place.match(/in `(block.*?in )?(.*?)'/)[2]

    lc = log_level_colors(level)

    depth_string = ''
    depth_string = " #{caller.length - 1}" if tracing
    leader = file_line.colorize(:light_black) + ' [' + meth.to_s.colorize(lc) + "#{depth_string}]"

    spacers = ''
    spacers = ' ' * ((caller.length - 1) / 2) if tracing

    spacers + leader + ' ' + message
  end

  def self.log_header(area, level, header)
    return unless log_level_leq(RDL::Config.instance.log_levels[area], level)

    stars = '***************'

    if RDL::Config.instance.log_levels[area] == :trace
      puts "#{log_str(area, level, header)} " + stars
    else
      puts stars + " #{log_str(area, level, header)} " + stars
    end

  end

  def self.log(area, level, message)
    return unless log_level_leq(RDL::Config.instance.log_levels[area], level)

    puts log_str(area, level, message)
  end

end
