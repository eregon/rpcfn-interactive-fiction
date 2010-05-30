module InteractiveFiction
  class Room < AbstractObject
    attr_reader :exits, :long_description
    attr_writer :world

    def objects
      @objects ||= if objects = @objects_str
        objects.split("\n").map { |name| Object.find(name, @world.objects) }
      else
        []
      end
    end

    def enter
      @seen = true
    end

    def description
      if (@seen ||= false)
        "You're #{@title}"
      else
        look
      end
    end

    def look
      [self, *objects].map(&:long_description).join("\n")
    end

    def << object
      objects << object if object
    end

    def >> object
      objects.delete(object)
    end

    class << self
      def find(room_name, rooms)
        rooms.find { |room|
          room.name == room_name
        }
      end
    end
  end
end
