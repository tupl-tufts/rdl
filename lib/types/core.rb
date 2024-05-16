require_relative "core/_aliases.rb" # load type aliases first
require_relative "core/array.rb" # and Array so we can use Array<T>
Dir[File.dirname(__FILE__) + "/core/**/*.rb"].each { |f| require f }
