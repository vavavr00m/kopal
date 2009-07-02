class KopalModel < ActiveRecord::Base
  self.abstract_class = true
  include KopalHelper
  Kopal::Database.establish_connection
end

