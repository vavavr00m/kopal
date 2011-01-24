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
  end
end