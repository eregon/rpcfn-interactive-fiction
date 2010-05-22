module InteractiveFiction
  class Synonyms < AbstractObject
    SEPARATOR = ", "
    def initialize(name, description)
      super
      @synonyms = @description.each_pair.with_object({}) { |(full, synonym), synonyms|
        synonyms[full] = synonym.split(SEPARATOR)
      }

      @all_synonyms = @synonyms.values.reduce(:+)
    end

    def get_full_command(synonym)
      if @all_synonyms.include? synonym
        @synonyms.keys.find { |key| @synonyms[key].include?(synonym) }
      else
        synonym
      end
    end
  end
end
