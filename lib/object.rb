module InteractiveFiction
  class Object < AbstractObject
    NAME_TOKEN = "$"
    attr_reader :terms, :long_description

    def small_description
      @terms.first
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
