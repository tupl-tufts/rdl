if Rails.env.development? || Rails.env.test?
  require 'rdl/boot'
  require 'types/core'

  require_relative "../types/rails/_helpers.rb" # load type aliases first
  Dir[File.dirname(__FILE__) + "/../types/rails/**/*.rb"].each { |f| require f }
  RDL.load_rails_schema
elsif Rails.env.production?
  require 'rdl_disable'
  class ActionController::Base
    def self.params_type(typs); end
  end
else
  raise RuntimeError, "Don't know what to do in Rails environment #{Rails.env}"
end
