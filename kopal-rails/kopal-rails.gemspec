
Gem::Specification.new do |spec|
  spec.name = "kopal-rails"
  spec.version = File.read(File.expand_path('../../VERSION', __FILE__)).strip
  spec.date = Time.now.utc
  spec.summary = "Distributed and Decentralised Social Networking Platform."
  spec.author = "Avik Prgati"
  spec.email = "nasa42+kopal@gmail.com"
  spec.homepage = "http://kopal.googlecode.com/"

  spec.files = Dir["**/*"] & `hg manifest`.split("\n").map { |f| f.gsub(/^kopal\//, '') }

  spec.add_dependency('kopal', spec.version)
  spec.add_dependency('rails', '~> 3.0')
  spec.add_dependency('rack-openid', '~> 1.3')
  spec.add_dependency('mongoid', '~> 2.0')

  spec.add_development_dependency('bson_ext')
end 
