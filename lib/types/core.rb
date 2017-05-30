require_relative "core/_aliases.rb" # load type aliases first
Dir[File.dirname(__FILE__) + "/core/**/*.rb"].each { |f| require f }
