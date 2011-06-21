
Gem::Specification.new do |spec|
  spec.name = "kopal-rails"
  spec.version = File.read(File.expand_path('../../VERSION', __FILE__)).strip
  spec.date = Time.now.utc
  spec.summary = "Distributed and Decentralised Social Networking Platform."
  spec.author = "Avik Prgati"
  spec.email = "nasa42+kopal@gmail.com"
  spec.homepage = "http://kopal.googlecode.com/"

  #spec.files = Dir["**/*"] & `hg manifest`.split("\n").map { |f| f.gsub(/^kopal\//, '') } 

  spec.add_dependency('kopal', spec.version)
  spec.add_dependency('rails', '~> 3.0')
  spec.add_dependency('mongoid', '>= 2.0')
  #How to avoid config conflicts with main application's config/initializers/formtastic.rb config 
  #like custom HTML classes etc? As that might make Kopal's form look weird.
  #spec.add_dependency('formtastic') #Doesn't seem to be loading automatically - undefined method `semantic_form_for'
  #spec.add_dependency('kaminari') #Doesn't seem to be loading - undefined method `page'
  spec.add_development_dependency('bson_ext')
end 
