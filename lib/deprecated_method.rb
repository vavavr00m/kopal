class DeprecatedMethod < StandardError

  #Raise DeprecatedMethod in devlopment/test, bypass silently in production.
  def self.here message = 'This method is deprecated.'
    raise DeprecatedMethod, message unless "production" == RAILS_ENV
    #raise and rescue to get the stack and email it in production environment.
    begin
      raise DeprecatedMethod, message
    rescue DeprecatedMethod => e
      ActiveSupport::Deprecation.warn message
      stack = e.backtrace.join("\n")
      #email => unraised exception message => , stack => 
    end
  end
end
