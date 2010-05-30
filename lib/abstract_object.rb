module InteractiveFiction
  class AbstractObject
    attr_reader :name
    def initialize(name, description)
      @name = name
      description.each_pair { |key, value|
        instance_variable_set :"@#{key}", value
        self.class.send(:attr_reader, key) unless self.respond_to?(key)
      }
    end

    def inspect
      "#{self.class.simple_name} #{@name}"
    end
    alias :to_s :inspect

    class << self
      def find(search, objects, method)
        objects.find { |object|
          case criteria = object.send(method)
          when Array
            criteria.include? search
          when String
            criteria == search
          end
        }
      end
    end
  end
end
