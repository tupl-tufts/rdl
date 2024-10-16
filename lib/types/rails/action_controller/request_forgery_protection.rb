# need to actually define a copy of this method, on ActionController::Base,
# to prevent errors.
class ActionController::Base
    def self.verify_authenticity_token
    end
end