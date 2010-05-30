require_relative "abstract_object"
module InteractiveFiction
  class Object < AbstractObject
    NAME_TOKEN = "$"
    def Object.find(name, objects)
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
