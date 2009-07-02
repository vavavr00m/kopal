class KopalModel < ActiveRecord::Base
  self.abstract_class = true
  include KopalHelper
end

