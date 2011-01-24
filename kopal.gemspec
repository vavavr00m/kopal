
Gem::Specification.new do |spec|
  spec.name = "kopal"
  spec.version = File.read(File.expand_path('../VERSION.txt', __FILE__))
  spec.date = Time.now.utc
  spec.summary = "Distributed and Decentralised Social Networking Platform."
  spec.author = "Avik Prgati"
  spec.email = "nasa42+kopal@gmail.com"
  spec.homepage = "http://kopal.googlecode.com/"
  spec.has_rdoc = false

  spec.files = Dir["**/*"] & `hg manifest`.split("\n")

  #"kopal" dependency
  spec.add_dependency('activesupport', '>= 3')
  #"kopal-rails" dependency
  spec.add_dependency('rails', '>= 3')
  spec.add_dependency('ruby-openid', '>= 2.1')
  spec.add_dependency('will_paginate')
end 
