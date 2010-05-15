class Kopal::ProfilePage < Kopal::KopalModel
  set_table_name "#{name_prefix}profile_page"

  VISIBILITIES = ['public', 'private', 'friend']

  has_many :widgets, :class => 'Kopal::PageWidget', :dependent => :destroy

  before_validation_on_create :fill_visibility

  validates_presence_of :page_name
  validates_presence_of :visibility
  validates_uniqueness_of :page_name, :scope => :kopal_account_id
  validates_inclusion_of :visibility, :in => VISIBILITIES

private

  def fill_visibility
    self[:visibility] = 'public' if visibility.blank?
  end
end