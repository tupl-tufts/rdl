module ActionDispatch
  module Routing
    class RouteSet
      post(:draw) { |ret|
#        puts "Routes are: #{Rails.application.routes.named_routes.helper_names}"
        true
      }
    end
  end
end
