# Install hook code here
require 'rake'
current_dir = File.dirname(__FILE__)
File.rename(current_dir, "#{current_dir}/../kopal") if
  File.basename(current_dir) == 'hg'
  
Rake::Task["kopal:update"].invoke
