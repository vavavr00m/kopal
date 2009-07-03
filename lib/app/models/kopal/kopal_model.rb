class Kopal::KopalModel < ActiveRecord::Base
  self.abstract_class = true
  include KopalHelper
  Kopal::Database.establish_connection

  def self.inherited(subclass)
    super
    #Tables are only in singlular case in Kopal.
    set_table_name Kopal::Database.name_prefix + subclass.to_s.gsub("Kopal::", '').underscore
  end
end

