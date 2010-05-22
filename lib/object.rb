module InteractiveFiction
  class Object < AbstractObject
    SEPARATOR = ", "
    NAME_TOKEN = "$"
    attr_reader :terms
    def initialize(name, description)
      super
      @terms = @description["Terms"].split(SEPARATOR)
      @long_description = @description["Description"]
    end

    def small_description
      @terms.first
    end

    def long_description
      @long_description
    end

    class << self
      def find(name, objects)
        objects.find { |o|
          o.name == name ||
          o.name == "#{NAME_TOKEN}#{name}" ||
          o.terms.any? { |term|
            term.casecmp(name).zero?
          }
        }
      end
    end
  end
end
