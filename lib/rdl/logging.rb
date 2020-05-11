require 'pry'

class RDL::Logging
  LEVELS = %i[
    trace debug debug_error info
    warning error critical
  ].freeze

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
    a_idx = LEVELS.find_index(a)
    b_idx = LEVELS.find_index(b)

    a_idx <= b_idx
  end

  def self.extract_file_line(str)
    match = str.match(/.*\/(.*?\.rb)(:([0-9]+))?/)
    match && [match[1] || '', match[3] || ''] || ['', '']
  end

  def self.log_str(area, level, message, message_color: nil)
    tracing  = RDL::Config.instance.log_levels[area] == :trace
    no_color = RDL::Config.instance.disable_log_colors

    place      = caller[1]
    file, line = extract_file_line(place)
    meth       = place.match(/in `(block.*?in )?(.*?)'/)

    meth = meth ? meth[2] : 'unknown'

    lc = log_level_colors(level)

    meth      = meth.to_s.colorize(lc) unless no_color
    file_line = "#{file}:#{line}".colorize(:light_black) unless no_color
    message   = message.colorize(message_color) if message_color && !no_color

    level_str = ''
    level_str = "#{level.to_s.upcase} " if no_color

    depth_string = ''
    depth_string = " #{caller.length - 1}" if tracing
    leader       = level_str + file_line + '[' + meth + "#{depth_string}]"

    spacers = ''
    spacers = ' ' * ((caller.length - 1) / 2) if tracing

    [spacers + leader + ' ' + message, (spacers + leader).uncolorize.length + 1]
  end

  def self.log_header(area, level, header)
    return unless log_level_leq(RDL::Config.instance.log_levels[area] || :info, level)
    no_color = RDL::Config.instance.disable_log_colors
    if no_color
      stars = "***************"
      str, = log_str(area, level, header, message_color: { mode: :bold }) + ' ' + stars
      puts "\n" + stars + ' ' + str
    else
      str, = log_str(area, level, header, message_color: { mode: :bold })
      puts "\n" + str
    end
  end

  def self.log(area, level, message, ast: nil)
    return unless log_level_leq(RDL::Config.instance.log_levels[area] || :info, level)

    str, len = log_str(area, level, message, message_color: :white)

    puts str
    puts ast_render len, ast.loc.expression if ast
    exit 1 if ast
  end

  ###### Borrowed from Diagnostic.rb ###########################################

  def self.ast_render(offset, location)
    first_line = first_line_only(location)
    last_line  = last_line_only(location)
    num_lines  = (location.last_line - location.line) + 1
    buffer     = location.source_buffer

    # location.column_range; .source; .source_buffer; .source_line

    lineno, column = buffer.decompose_position(location.begin_pos)
    last_lineno, last_column = buffer.decompose_position(location.end_pos)

    file_name, = extract_file_line(buffer.name)
    source_loc = "#{file_name}:"
    unless RDL::Config.instance.disable_log_colors
      source_loc = source_loc.colorize(:light_black)
    end

    [' ' * offset + source_loc + "#{lineno}:#{column} - #{last_lineno}:#{last_column}"] +
      render_line(offset, first_line, num_lines > 2, false) +
      render_line(offset, last_line, false, true)
  end

  ##
  # Renders one source line in clang diagnostic style, with highlights.
  #
  # @return [Array<String>]
  #
  def self.render_line(offset, range, ellipsis=false, range_end=false)
    source_line    = range.source_line
    highlight_line = ' ' * source_line.length

    # @highlights.each do |highlight|
    #   line_range = range.source_buffer.line_range(range.line)
    #   if highlight = highlight.intersect(line_range)
    #     highlight_line[highlight.column_range] = '~' * highlight.size
    #   end
    # end

    if range.is?("\n")
      highlight_line += "^"
    else
      if !range_end && range.size >= 1
        highlight_line[range.column_range] = '^' + '~' * (range.size - 1)
      else
        highlight_line[range.column_range] = '~' * range.size
      end
    end

    highlight_line += '...' if ellipsis
    file_name, = extract_file_line(range.source_buffer.name)

    [source_line, highlight_line].map do |line|
      source_loc = "#{file_name}:#{range.line}:"
      unless RDL::Config.instance.disable_log_colors
        source_loc = source_loc.colorize(:light_black)
      end

      ' ' * offset + source_loc + " #{line}"
    end
  end

  ##
  # If necessary, shrink a `Range` so as to include only the first line.
  #
  # @return [Parser::Source::Range]
  #
  def self.first_line_only(range)
    if range.line != range.last_line
      range.resize(range.source =~ /\n/)
    else
      range
    end
  end

  ##
  # If necessary, shrink a `Range` so as to include only the last line.
  #
  # @return [Parser::Source::Range]
  #
  def self.last_line_only(range)
    if range.line != range.last_line
      range.adjust(begin_pos: range.source =~ /[^\n]*\z/)
    else
      range
    end
  end
end
