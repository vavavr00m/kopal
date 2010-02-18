require 'rake'
require 'rake/testtask'
require 'rubygems'
begin
  require 'hanna/rdoctask'
rescue LoadError
  require 'rake/rdoctask'
end

begin
  require 'yard'
  
  #TODO: include all classes including vendor, test and everything.
  #TODO: include Google Analytics. Like if exists? ./.hg/.doc_google_analytics then include it.
  desc "Generate documentation using YARD."
  YARD::Rake::YardocTask.new(:yard) do |yard|
    yard.files = ['**/*.rb']
    yard.options <<
      "--title=Kopal API" <<
      "--files=LICENCE.txt,Attributions.txt"
  end
rescue LoadError
  #skip
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the Kopal plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/{kopal,functional,unit}/*_test.rb'
  t.verbose = true
end

desc 'Tests related with network activity.'
Rake::TestTask.new(:"test-network") do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/network/*_test.rb'
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
