module InteractiveFiction
  class Player
    def initialize(world)
      @world = world
      @inventory = []
      @blackboard = {}
    end

    def << object
      if object
        @inventory << object
        "OK"
      end
    end

    def >> object
      @inventory.delete(object)
    end

    def show_inventory
      if @inventory.empty?
        "You're not carrying anything"
      else
        @inventory.map { |object|
          object.small_description
        }.join("\n")
      end
    end

    # block code methods
    attr_accessor :blackboard
    def player_in?(room_name)
      @world.current_room == Room.find(room_name, @world.rooms)
    end

    def player_has?(object_name)
      @inventory.include? Object.find(object_name, @world.objects)
    end
  end
end
