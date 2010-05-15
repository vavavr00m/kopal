class Kopal::PageWidget < Kopal::Model
  set_table_name "#{name_prefix}page_widget"

  belongs_to :page, :class => 'Kopal::ProfilePage'
  has_many :records, :class => 'Kopal::ProfileStore',
    :primary_key => 'widget_key', :foreign_key => 'widget_key',
    :dependent => :destroy

  before_validation_on_create :assign_widget_key
  before_validation_on_create :assign_position

  validates_presence_of :page_id
  validates_presence_of :widget_uri
  validates_presence_of :widget_key
  validates_presence_of :position
  validates_uniqueness_of :widget_key
  validates_length_of :widget_key, :maximum => 64 #512-bit max

private

  #widget_key can be of variable length with maximum 512 bit.
  def assign_widget_key
    #default is 32.
    begin
      self[:widget_key] = random_hexadecimal
    end while(self.class.find_by_widget_key(widget_key)) if widget_key.blank?
  end

  def assign_position
    self[:position] = 0 if position.blank?
  end
end