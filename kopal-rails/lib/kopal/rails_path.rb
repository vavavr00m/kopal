#DEPRECATION WARNING: I belive that we can do without it. 
#And since Kopal is now an Engine, paths are available as Kopal::Engine.config.paths if we ever need them which I don't think is likely anyway.
class Kopal::RailsPath

  class << self
    def to_s
      root
    end

    def root
      Kopal.path.root.join('rails')
    end
    alias rails root

    def app
      rails.join('app')
    end

    def views
      app.join('views')
    end

    def db
      rails.join('db')
    end

    def migrate
      db.join('migrate')
    end

    def config
      rails.join('config')
    end

    def routes
      config.join('routes.rb')
    end
  end
end

Kopal::Path.instance_eval do
  def rails
    Kopal::RailsPath
  end
end