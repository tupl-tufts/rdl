
class RDL::Logging
  def self.log_level_colors(a)
    colors = {
      trace: :yellow,
      debug: :green,
      debug_error: :red,
      info: :light_green,
      warning: :light_yellow,
      error: :light_red,
      critical: { color: :light_red, mode: :bold }
    }
    colors[a]
  end

  def self.log_level_leq(a, b)
    levels = [:trace, :debug, :debug_error, :info, :warning, :error, :critical]
    a = levels.find_index(a)
    b = levels.find_index(b)

    raise "#{a} is not a valid log level; valid levels are #{levels}" unless a
    raise "#{b} is not a valid log level; valid levels are #{levels}" unless b

    a <= b
  end

  def self.log_str(area, level, message, message_color: nil)
    tracing = RDL::Config.instance.log_levels[area] == :trace
    no_color = RDL::Config.instance.disable_log_colors

    place = caller.find { |s| s.include?('lib/rdl') && !s.include?('in `log') }
    file_line = place.match(/.*\/(.*?\.rb:[0-9]+)/)[1]
    meth = place.match(/in `(block.*?in )?(.*?)'/)[2]

    lc = log_level_colors(level)

    meth = meth.to_s.colorize(lc) unless no_color
    file_line = file_line.colorize(:light_black) unless no_color
    message = message.colorize(message_color) if message_color && !no_color

    level_str = ''
    level_str = "#{level.to_s.upcase} " if no_color

    depth_string = ''
    depth_string = " #{caller.length - 1}" if tracing
    leader = level_str + file_line + ' [' + meth + "#{depth_string}]"

    spacers = ''
    spacers = ' ' * ((caller.length - 1) / 2) if tracing

    spacers + leader + ' ' + message
  end

  def self.log_header(area, level, header)
    return unless log_level_leq(RDL::Config.instance.log_levels[area], level)
    no_color = RDL::Config.instance.disable_log_colors
    if no_color
      stars = "***************"
      puts "\n" + stars + ' ' + log_str(area, level, header, message_color: { mode: :bold }) + ' ' + stars
    else
      puts "\n" + log_str(area, level, header, message_color: { mode: :bold })
    end
  end

  def self.log(area, level, message)
    return unless log_level_leq(RDL::Config.instance.log_levels[area], level)

    puts log_str(area, level, message, message_color: :white)
  end

end
