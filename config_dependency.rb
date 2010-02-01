Rails.configuration.gem 'ruby-openid', :lib => 'openid', :version => '>= 2.1.7'
Rails.configuration.gem 'sqlite3-ruby', :lib => 'sqlite3'
#Remove following dependencies and make code utilise them only if they are available.
Rails.configuration.gem 'gemcutter' #For will_paginate.
Rails.configuration.gem 'will_paginate'
