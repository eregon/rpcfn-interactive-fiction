module InteractiveFiction
  class AbstractObject
    attr_reader :name, :description
    def initialize(name, description)
      @name = name
      if description.keys.all? { |key| Symbol === key }
        description.each_pair { |key, value|
          instance_variable_set "@#{key}", value
        }
      else
        @description = description
      end
    end

    def inspect
      "#{self.class.simple_name} #{@name}"
    end
    alias :to_s :inspect
  end
end
