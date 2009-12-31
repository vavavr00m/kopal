class Kopal::KopalModel < ActiveRecord::Base
  self.abstract_class = true
  include Kopal::KopalHelper
  Kopal.database.establish_connection

  def self.inherited(subclass)
    super 
    #Tables are only in singular case in Kopal.
    #
    #This doesn't seem to work.
    #For example, if I -
    #ModelA.find_something()
    #ModelB.find_something()
    #ModelA.find_something() -- Will look in table "model_b"!!
    #I _guess_ this is because, (don't know why) all models all the time share
    #same table name. When ModelA is called first time, all models get the table
    #name "model_a". When ModelB is called for first time, all models get the
    #table name "model_b". When ModelA is called for second time, this method
    #doesn't seem to invoke, and table name stays "model_b".
    #This went unnoticed so far because in initial development stage, I never came
    #through this situation. A few days before, tests started showing this error, and
    #today in development mode while developing profile pages, where I was able
    #to debug.
    #
    #
    #set_table_name Kopal::Database.name_prefix + subclass.to_s.gsub("Kopal::", '').underscore
  end
end

