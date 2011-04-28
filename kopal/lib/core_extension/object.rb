class Object
  
  def or_on_blank value
    self.blank? ? value : self
  end
  
  #Provides a local envrionment where the scope of captured object is defined. (What?)
  #
  #same as C#'s using statement - http://msdn.microsoft.com/en-us/library/yh598w02.aspx
  #
  #Same as tap() but returns the block-value instead of self.
  #
  #bascially so that instead of assiging the value to a variable that is not going to 
  #be used more than once, we can write this in one line using chaining rather than using multiple lines.
  #
  # #without capture
  #x = a_very_very_long_array_variable_name
  #first, fourth = x.first, x.fourth
  #
  # #with capture
  #first, fourth = a_very_very_long_array_variable_name.capture { |x| [x.first, x.fourth] }
  #
  #TODO: provide a better example (maybe more than 1) that justify the existence of this method.
  #
  #Should change the name as Rails also defines a capture method. "using" sounds ok.
  def capture
    yield self
  end
  alias using capture
end