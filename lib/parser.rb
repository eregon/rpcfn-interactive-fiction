module InteractiveFiction
  class Parser
    TAB = " "*2
    SEPARATOR = /:(?=\s)/
    COMMA_SEPARATOR = ", "
    NO_INDENT = /\A(?!\s)/
    GROUP_TITLE = /\A(\w+)(?:\s(.\w+))?:\z/

    BEGIN_CODE = /^#{Regexp.escape("{{{")}/
    END_CODE = /#{Regexp.escape("}}}")}$/
    ROOM_EXIT_SEPARATOR = " "

    def initialize(file)
      @file = file
    end

    def unindent(str)
      str.sub(/\A#{TAB}/,'')
    end

    def parse
      lines = IO.read(@file).lines.map(&:chomp)
      lines.slice_before(NO_INDENT).reject { |o| o.all?(&:empty?) }.inject([]) { |objects,lines|
        lines.shift =~ GROUP_TITLE
        type, name = $1, $2
        objects << if self.respond_to?("parse_#{type.downcase}")
          send("parse_#{type.downcase}", name, parse_contents(lines))
        else
          InteractiveFiction.const_get(type).new(name, parse_contents(lines))
        end
      }
    end

    def parse_contents(lines)
      lines.map { |l| unindent(l) }.slice_before(NO_INDENT).each_with_object({}) { |key_value, contents|
        key, *value = key_value.map(&:strip).join("\n").split(SEPARATOR)
        value = unindent value.join.lstrip

        contents[key] = value
      }
    end

    def Parser.parse_code(code)
      code.lines.to_a[1...-1].join.
      gsub(/\bblackboard\b/, '@blackboard') # Very weird bug, the method call fail if we add actions ???
      # Else we get: "undefined method `[]' for nil:NilClass (NoMethodError)"
      # Apparently instance_eval consider blackboard as a local var in this case
    end

    def Parser.parse_room_exits(text)
      text.lines.slice_before(/\A\w+ to/).each_with_object({}) { |exit, h|
        if exit.size > 1 and code = exit.join and code =~ BEGIN_CODE and code =~ END_CODE
          # enter to @grate_chamber guarded by:
          code =~ /(\w+) to (.+) guarded by\n/
          h[$1] = [$2, Parser.parse_code($')]
        else
          dir, to, room = exit.first.split(ROOM_EXIT_SEPARATOR)
          h[dir] = room
        end
      }
    end

    def parse_room(name, description)
      Room.new name,
        :exits => Parser.parse_room_exits(description["Exits"]),
        :title => description["Title"].rstrip.end_with!("."),
        :long_description => description["Description"],
        :objects_str => description["Objects"]
    end

    def parse_object(name, description)
      Object.new name,
        :terms => description["Terms"].split(COMMA_SEPARATOR),
        :long_description => description["Description"]
    end
  end
end
