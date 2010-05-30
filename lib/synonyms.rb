module InteractiveFiction
  class Synonyms < AbstractObject
    def get_full_command(synonym)
      if @all_synonyms.include? synonym
        @synonyms.keys.find { |key| @synonyms[key].include?(synonym) }
      else
        synonym
      end
    end
  end
end
