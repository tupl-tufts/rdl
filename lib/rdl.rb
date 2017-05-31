# This wrapper file allows us to completely disable RDL in certain modes.
$LOAD_PATH << '/Users/jfoster/proj/rdl/lib'

if defined?(Rails)
  require 'rdl/boot_rails'
else
  require 'rdl/boot'
end
