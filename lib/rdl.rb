# This wrapper file allows us to completely disable RDL in certain modes.
if defined?(Rails)
  require 'active_record' if !defined?(ActiveRecord)
  require 'rdl/boot_rails'
else
  require 'rdl/boot'
end
