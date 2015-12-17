dir = RUBY_VERSION.split('.')[0] + ".x"

require_rel "../types/ruby-#{dir}/_aliases.rb" # load type aliases first
require_rel "../types/ruby-#{dir}/*.rb"
