#Loading them here, since kopal.rb is loaded on every request, and these files are BIG.
I18n.load_path += Dir[File.dirname(__FILE__) + '/lib/culture/*.{rb,yml}']
I18n.load_path += Dir[File.dirname(__FILE__) + '/lib/culture/code/*/*.{rb,yml}']

require 'kopal'
