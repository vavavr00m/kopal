class DeprecatedMethod < StandardError

  #Raise DeprecatedMethod in devlopment/test, bypass silently in production.
  #
  #1. For first release (message, false)
  #2. For next release (message, true)
  def self.here message = 'This method is deprecated.', raise_error_in_development = false
    raise_error_in_development = false if "production" == RAILS_ENV
    ActiveSupport::Deprecation.warn message
    raise DeprecatedMethod, message if raise_error_in_development
    #raise and rescue to get the stack and email it in production environment.
    begin
      raise DeprecatedMethod, message
    rescue DeprecatedMethod => e
      stack = e.backtrace.join("\n")
      #email => unraised exception message => , stack => 
    end
  end
end

