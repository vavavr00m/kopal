class Kopal::PageWidget < Kopal::Model

  field :widget_uri
  field :widget_key
  field :position, :type => Integer, :default => 0

  #TODO: is it unique across all widgets or just within the page it is embedded to.
  index :widget_key, :unique => true

  embedded_in :page, :inverse_of => :widgets, :class_name => 'Kopal::ProfilePage'
  #LATER: Is it possible that only a given widget can access a given private record.
  #       So that another widget can not access data of a private list just
  #       because it knows the widget key of widget with which this list belongs and user is signed in.
  embeds_many :records, :class_name => 'Kopal::ProfileStore'

  before_validation_on_create :assign_widget_key

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
end