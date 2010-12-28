class Kopal::Path

  class << self

    def root
      @root ||= Pathname.new KOPAL_ROOT
    end

    def lib
      root.join('lib')
    end

    def tasks
      lib.join('tasks')
    end

    def rails
      root.join('rails')
    end

    def db
      rails.join('db')
    end

    def migrate
      db.join('migrate')
    end
  end
end