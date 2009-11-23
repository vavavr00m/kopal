class Kopal::Version
  attr_reader :type, :revision, :year, :major, :stage, :minor
  alias version revision
  alias to_s revision

  def self.current
   self.new Kopal::SOFTWARE_VERSION
  end

  def self.compare r1, r2
    r1 = self.new(r1) if r1.is_a? String
    r2 = self.new(r2) if r2.is_a? String
    raise TypeError, "Can't compare between #{r1.class} and #{r2.class}" unless
      r1.is_a? self and r2.is_a? self
    raise TypeError, "Can not compare two distinct version types." unless
      r1.type == r2.type
    if r1.type == 'software'
      year = r1.year <=> r2.year
      return year unless year.zero?
      major = r1.major <=> r2.major
      return major unless major.zero?
      stage = r1.stage_index <=> r2.stage_index
      return stage unless stage.zero?
      minor = r1.minor <=> r2.minor
      return minor
    end
  end

  #Pass +:type => 'spec'+ for explicitly making it a spec revision. Or it is
  #determined automatically.
  #options { :type => 'software' or 'spec' }
  def initialize revision = SOFTWARE_VERSION, options = {}
    @revision = revision.strip
    @type = options[:type] || if @revision.index(".") == 4
      'software' else 'draft'
    end
    send "interpret_#{@type}_release_type"
  end

  def year
    raise NoMethodError unless @type == "software"
    @year
  end

  #returns 'alpha', 'beta', 'rc', 'gamma'
  def software_release_stage
   @stage
  end

  def stage_index
    if @stage == 'rc' then 'c' else @stage[0].chr end
  end

  def software_channel
    if stage_index == 'g' then 'stable' else 'preview' end
  end

  def <=> right
    self.class.compare(self, right)
  end
  alias compare <=>

private

  def interpret_software_release_type
   raise_number_invalid if @revision.count(".") >= 4
   @year, @major, @stage, @minor = @revision.split('.')
   @year = @year.to_i
   @major = @major.to_i
   @stage ||= 'g'
   @minor ||= 1
   @minor = @minor.to_i
   @stage = fully_qualified_stage_name @stage
   raise_number_invalid if @year.zero? or @minor.zero?
  end

  def fully_qualified_stage_name stage
   return 'alpha' if stage =~ /^a/i
   return 'beta' if stage =~ /^b/i
   return 'rc' if stage =~ /^r?c/i
   return 'gamma' if stage =~ /^g/i
   raise_number_invalid
  end

  def raise_number_invalid
   raise Kopal::Version::NumberInvalid, "Invalid version number #{@revision}"
  end
  
end