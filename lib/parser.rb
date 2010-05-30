module InteractiveFiction
  class Parser
    INDENT = " "*2
    NO_INDENT = /\A(?!#{INDENT})/

    KEY_VALUE_SEPARATOR = /:(?=\s)/
    LIST_SEPARATOR = ", "
    ROOM_EXIT_SEPARATOR = " "

    GROUP_TITLE = /\A(\w+)(?:\s(.\w+))?:\z/

    BEGIN_CODE = /^#{Regexp.escape("{{{")}/
    END_CODE = /#{Regexp.escape("}}}")}$/

    def initialize(file)
      @file = file
    end

    def parse
      IO.read(@file).lines.map(&:chomp).
      slice_before(NO_INDENT).reject { |o| o.all?(&:empty?) }.inject([]) { |objects, lines|
        lines.shift =~ GROUP_TITLE
        type, name = $~.captures # With 1.8, we can't use Regexp named groups
        objects << send("parse_#{type.downcase}", name, parse_contents(lines))
      }
    end

    def parse_contents(lines)
      lines.map(&:unindent).slice_before(NO_INDENT).each_with_object({}) { |key_value, contents|
        key, *value = key_value.map(&:strip).join("\n").split(KEY_VALUE_SEPARATOR)

        contents[key] = value.join.lstrip.unindent
      }
    end

    def parse_code(code)
      code =~ /#{BEGIN_CODE}(.+)#{END_CODE}/m
      $1.gsub(/\bblackboard\b/, 'self.blackboard')
      # Very weird bug, the method call fail if we add actions ???
      # Else we get: "undefined method `[]' for nil:NilClass (NoMethodError)"
      # Apparently instance_eval consider blackboard as a local var (with a nil value) in this case
    end

    def parse_room_exits(text)
      text.lines.slice_before(/\A\w+ to/).each_with_object({}) { |exit, h|
        if exit.size > 1 and code = exit.join and code =~ BEGIN_CODE and code =~ END_CODE
          # enter to @grate_chamber guarded by:
          code =~ /(\w+) to (.+) guarded by\n/
          h[$1] = [$2, parse_code($')]
        else
          dir, to, room = exit.first.split(ROOM_EXIT_SEPARATOR)
          h[dir] = room
        end
      }
    end

    def parse_room(name, desc)
      Room.new name,
        :exits => parse_room_exits(desc["Exits"]),
        :title => desc["Title"].rstrip.end_with!("."),
        :long_description => desc["Description"],
        :objects_names => (desc["Objects"] || "").split("\n")
    end

    def parse_object(name, desc)
      terms = desc["Terms"].split(LIST_SEPARATOR)
      Object.new name,
        :terms => terms,
        :small_description => terms.first,
        :long_description => desc["Description"]
    end

    def parse_action(name, desc)
      Action.new name,
        :commands => desc["Terms"].split(LIST_SEPARATOR),
        :code => parse_code(desc["Code"])
    end

    def parse_synonyms(name, desc)
      synonyms = desc.each_pair.with_object({}) { |(full, synonym), synonyms|
        synonyms[full] = synonym.split(LIST_SEPARATOR)
      }
      Synonyms.new name,
        :synonyms => synonyms,
        :all_synonyms => synonyms.values.reduce(:+)
    end
  end
end
