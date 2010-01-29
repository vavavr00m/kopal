require 'rake'
require 'rake/testtask'
require 'rubygems'
begin
  require 'hanna/rdoctask'
rescue LoadError
  require 'rake/rdoctask'
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the Kopal plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the Kopal plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'Kopal'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.txt')
  rdoc.rdoc_files.include('**/*.rb')
  rdoc.rdoc_files.exclude(/^(test|vendor|lib\/db)/)
end
