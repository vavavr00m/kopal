#Scope: (default is 1)
# scope | public read | public write
#   0   |     0       |      0
#   1   |     1       |      0
#   2   |     1       |      1
#
#TODO: Add field page_scope - only friends can view, or a friend group can view etc.
class Kopal::ProfileStore < Kopal::Model
  set_table_name "#{name_prefix}profile_store"

  belongs_to :widget, :class_name => 'Kopal::PageWidget',
    :primary_key => 'widget_key', :foreign_key => 'widget_key'

  before_validation_on_create :assign_scope

  validates_presence_of :widget_key
  #TODO: Rename "record" to something more meaningful.
  validates_presence_of :record_name
  validates_uniqueness_of :record_name, :scope => :widget_key
  validates_inclusion_of :scope, :in => [0,1,2]

private

  def assign_scope
    self[:scope] = 1 if self[:scope].nil?
  end
end