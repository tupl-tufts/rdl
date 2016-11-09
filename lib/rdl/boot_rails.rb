if Rails.env.development? || Rails.env.test?
  require 'rdl/boot'
  require 'types/core'

  version = Rails::VERSION::STRING.split('.')[0] + ".x"

  begin
    require_relative "../types/rails-#{version}/_helpers.rb" # load type aliases first
    Dir[File.dirname(__FILE__) + "/../types/rails-#{version}/**/*.rb"].each { |f| require f }
  rescue LoadError
    $stderr.puts("rdl could not load type definitions for Rails v#{version}")
  end
elsif Rails.env.production?
  require 'rdl_disable'
  class ActionController::Base
    def self.params_type(typs); end
  end
else
  raise RuntimeError, "Don't know what to do in Rails environment #{Rails.env}"
end
