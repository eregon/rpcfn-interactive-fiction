require_relative "abstract_object"
module InteractiveFiction
  class Action < AbstractObject
    class << self
      def find(action_name, actions)
        super(action_name, actions, :commands)
      end
    end
  end
end
