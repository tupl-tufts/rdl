dir = RUBY_VERSION.split('.')[0] + ".x"

require_relative "../types/ruby-#{dir}/_aliases.rb" # load type aliases first
Dir[File.dirname(__FILE__) + "/../types/ruby-#{dir}/*.rb"].each { |f| require f }
