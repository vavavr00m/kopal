class String

  #If +to_s().blank?()+ then provide a default text.
  #Good, if "self" is a_very_long_variable_name_or_method_call, which Kopal has many.
  def with_default default_string
    blank?() ? default_string  : self
  end
  
end
