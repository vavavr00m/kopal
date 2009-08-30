class Kopal::ProfilePage < Kopal::KopalModel
  set_table_name 'profile_page'

  serialize :page_text

  validates_presence_of :page_name
  validates_uniqueness_of :page_name
  validates_format_of :page_name, :with => /^[^\/?#]*$/, :message => "can not contain '/', '?' and '\#'"

  #There should be something like -> :before_initialise_of_new_record
  before_validation_on_create :initialise_page_text
  before_validation :underscored_page_name

  def validate
    if self[:page_name].to_s.downcase == 'identity' #Can't use validates_exclusion_of, case-sensitive.
      errors.add(:page_name, "can't be named \"Identity\".")
    end
    #This one should never occur.
    errors.add(:page_name, "must not contain whitespaces") if self[:page_name][' ']
  end

  def self.page_name_list
    #Efficiencise!
    Kopal::ProfilePage.find(:all).map { |x| x.page_name }
  end

  def page_description
    page_text[:meta][:page_description]
  end

  def page_description= value
    page_text[:meta][:page_description] = value
  end

  #Returns an array of elements, in sorted order. Then new ones at first.
  def elements
    element_hash = page_text[:element].dup
    elements = []
    page_text[:meta][:sorting_order].each {|id|
      elements << element_hash.delete(id) if element_hash[id] #No nil's
    }
    rest = element_hash.values.sort {|x,y| y[:id] <=> x[:id]}
    elements = elements.insert(0, *rest) unless rest.blank?
    return elements
  end

	def insert_element element
    element[:id] = page_text[:meta][:last_assigned_id] += 1
    page_text[:element][element[:id]] = element
		save!
		return element[:id]
	end

  def delete_element element_id
    r = page_text[:element].delete element_id
    save
    return r
  end

  def to_s
    whitespaced page_name, '-'
  end

private
  #First Id should be 1, !0, logic depends on it.
  def initialise_page_text
    unless self[:page_text].instance_of? Hash
      self[:page_text] = { :meta => {:last_assigned_id => 0, :sorting_order => []}, :element => {}}
    end
  end

	def underscored_page_name
		self[:page_name] = "#{self[:page_name]}"
		return unless self[:page_name][' ']
		self[:page_name].strip!
		self[:page_name].gsub!('_', ' ')
		self[:page_name].gsub!('  ', ' ') while self[:page_name]['  ']
		self[:page_name].gsub!(' ', '_')
	end
end