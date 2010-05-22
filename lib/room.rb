module InteractiveFiction
  class Room < AbstractObject
    attr_reader :exits, :long_description
    attr_writer :world
    def initialize(name, description)
      super

      @exits = Parser.parse_room_exits @description["Exits"]

      @title = @description["Title"].rstrip.end_with!(".")
      @long_description = @description["Description"]
      @objects_str = @description["Objects"]

      @seen = false
    end

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
      if @seen
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
