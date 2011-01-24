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