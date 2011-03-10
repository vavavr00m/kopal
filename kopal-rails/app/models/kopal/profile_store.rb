#Scope: (default is 1)
# scope | public read | public write
#   0   |     0       |      0
#   1   |     1       |      0
#   2   |     1       |      1
#
#TODO: Add field page_scope - only friends can view, or a friend group can view etc.
class Kopal::ProfileStore < Kopal::Model

  field :record_name
  field :record_text
  field :scope, :type => Integer, :default => 1
  embedded_in :widget, :inverse_of => :records, :class_name => 'Kopal::PageWidget'
  index :record_name, :unique => true


  validates_presence_of :widget_key
  #TODO: Rename "record" to something more meaningful.
  validates_presence_of :record_name
  validates_uniqueness_of :record_name, :scope => :widget_key
  validates_inclusion_of :scope, :in => [0,1,2]

private

end