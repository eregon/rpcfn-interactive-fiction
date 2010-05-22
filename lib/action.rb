module InteractiveFiction
  class Action < AbstractObject
    SEPARATOR = ", "
    attr_reader :code, :commands
    def initialize(name, description)
      super
      @commands = @description["Terms"].split(SEPARATOR)
      @code = Parser.parse_code @description["Code"]
    end

    class << self
      def find(action_name, actions)
        actions.find { |action|
          action.commands.include? action_name
        }
      end
    end
  end
end
