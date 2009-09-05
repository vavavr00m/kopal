# Install hook code here
require 'rake'
current_dir = File.dirname(__FILE__)
File.rename(current_dir, "#{current_dir}/../kopal") if
  File.basename(current_dir) == 'hg'

puts "\n\nNote: **** Please run \"rake kopal:update RAILS_ENV=production\" to update Kopal. ****\n"
