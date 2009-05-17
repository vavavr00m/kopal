class DeprecatedMethod < StandardError
  
  def self.here message = 'This method is deprecated.'
    raise DeprecatedMethod, message unless RAILS_ENV == "production"
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

