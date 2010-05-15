class Kopal::ProfileStore < Kopal::Model
  set_table_name "#{name_prefix}profile_store"

  belongs_to :widget, :class => 'Kopal::PageWidget',
    :primary_key => 'widget_key', :foreign_key => 'widget_key'

  before_validation_on_create :assign_scope

  validates_presence_of :widget_key
  #TODO: Rename "record" to something more meaningful.
  validates_presence_of :record_name
  validates_presence_of :scope
  validates_uniqueness_of :record_name, :scope => :widget_key

private

  def assign_scope
    self[:scope] = scope.to_i
  end
end