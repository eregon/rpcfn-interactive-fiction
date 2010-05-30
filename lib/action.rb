module InteractiveFiction
  class Action < AbstractObject
    attr_reader :code, :commands
    class << self
      def find(action_name, actions)
        actions.find { |action|
          action.commands.include? action_name
        }
      end
    end
  end
end
