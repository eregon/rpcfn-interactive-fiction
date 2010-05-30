require_relative "abstract_object"
module InteractiveFiction
  class Room < AbstractObject
    attr_writer :world
    def objects
      @objects ||= @objects_names.map { |name| Object.find(name, @world.objects) }
    end

    def enter
      @seen = true
    end

    def description
      (@seen ||= false) ? "You're #{@title}" : look
    end

    def look
      [self, *objects].map(&:long_description).join("\n")
    end

    def << object
      objects << object if object
    end

    def >> object
      objects.delete object
    end

    def Room.find(room_name, rooms)
      super(room_name, rooms, :name)
    end
  end
end
