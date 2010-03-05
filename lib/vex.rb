if !defined?(VEX_TEST)
  VEX_TEST=""
end

require "#{File.dirname(__FILE__)}/vex/boot"
Vex.load_directory "base"

Vex.load_directory "active_record" if defined?(ActiveRecord)
Vex.load_directory "action_controller" if defined?(ActionController)
