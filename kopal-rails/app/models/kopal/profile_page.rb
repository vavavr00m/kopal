class Kopal::ProfilePage < Kopal::Model
  VISIBILITIES = ['public', 'private', 'friend']

  field :page_name
  field :page_description
  field :visibility, :default => 'public'

  index :page_name, :unique => true

  embeds_many :elements, :class_name => 'Kopal::PageWidget'

  validates_presence_of :page_name
  validates_presence_of :visibility
  validates_uniqueness_of :page_name, :scope => :kopal_account_id
  validates_inclusion_of :visibility, :in => VISIBILITIES
  validates_format_of :page_name, :with => /^[^\/?#]*$/, :message => "can not contain '/', '?' and '\#'"

  before_validation :underscored_page_name

  def validate
    if self[:page_name].to_s.downcase == 'identity' #Can't use validates_exclusion_of, case-sensitive.
      errors.add(:page_name, "can't be named \"Identity\".")
    end
    #This one should never occur.
    errors.add(:page_name, "must not contain whitespaces") if self[:page_name][' ']
  end

  def self.recursively_assign_page_name kopal_account_id, name
    p = self.new
    p.kopal_account_id = kopal_account_id
    p.page_name = name
    i = 1
    while self.find_by_kopal_account_id_and_page_name(p.kopal_account_id, p.page_name)
      p.page_name = "#{p.page_name}-#{i+=1}"
      raise SystemStackError if i > 10000 #Too much looping, save from infinity.
    end
    return p
  end

  def to_s
    whitespaced page_name, '-'
  end

private

  def underscored_page_name
		self[:page_name] = "#{self[:page_name]}"
		return unless self[:page_name][' ']
		self[:page_name].strip!
		self[:page_name].gsub!('_', ' ')
		self[:page_name].gsub!('  ', ' ') while self[:page_name]['  ']
		self[:page_name].gsub!(' ', '_')
	end
end