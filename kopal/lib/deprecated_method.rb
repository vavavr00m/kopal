class DeprecatedMethod < StandardError

  #Raise DeprecatedMethod in devlopment/test, bypass silently in production.
  #
  #1. For first release (message, false)
  #2. For next release (message, true)
  def self.here message = 'This method is deprecated.', raise_error_in_development = false
    raise_error_in_development = false if "production" == Rails.env
    raise DeprecatedMethod, message if raise_error_in_development
    #email it in production environment.
    #email => unraised exception message => , stack =>
    #ActiveSupport::Deprecation.warn message, caller
    message = "DEPRECATION WARNING: #{message}"
    if Rails.logger
      Rails.logger.warn message
    else
      puts message
    end
  end
end

