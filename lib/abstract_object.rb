module InteractiveFiction
  class AbstractObject
    attr_reader :name, :description
    def initialize(name, description)
      @name, @description = name, description
    end

    def inspect
      "#{self.class.simple_name} #{@name}"
    end
    alias :to_s :inspect
  end
end
