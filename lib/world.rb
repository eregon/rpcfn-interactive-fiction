module InteractiveFiction
  class World
    INPUT_SEPARATOR = " "
    MOVES = %w[north east south west]
    QUIT = %w[q quit]
    attr_reader :current_room
    def initialize(objects, input, output)
      @input, @output = input, output

      objects.group_by(&:class).each_pair { |klass, value|
        name = klass.simple_name.downcase.end_with!("s")
        instance_variable_set "@#{name}", value
        self.class.send(:attr_reader, name) unless self.respond_to?(name)
      }

      @player = Player.new(self)

      @rooms.each { |room| room.world = self }

      change_room @rooms.first
    end

    def puts(*args)
      @output.puts(*args)
    end

    def start!
      puts @current_room.long_description
    end

    def change_room(room)
      @current_room = room
      room.enter
    end

    def enter_room(room)
      room = Room.find(room, @rooms)
      puts room.description
      change_room(room)
    end

    def execute_one_command!
      if input = @input.gets and input.chomp! and !QUIT.include?(input)
        input = input.split(INPUT_SEPARATOR)
        command, args = input.shift, input
        @synonyms.each { |synonym| command = synonym.get_full_command(command) }
        input = args.unshift(command).join(INPUT_SEPARATOR)

        if dir = @current_room.exits[input]
          case dir
          when Array # With Proc
            room, code = dir
            allow, message = @player.instance_eval(code) # [ALLOW, MESSAGE]
            enter_room(room) if allow
            puts message
          when String
            enter_room dir
          end

        elsif MOVES.include? input
          puts "There is no way to go in that direction"

        elsif action = Action.find(input, @actions)
          message, blackboard = @player.instance_eval(action.code) # [MESSAGE, BLACKBOARD]
          puts message
          @player.blackboard.merge!(blackboard)

        else
          case input
          when "look"
            puts @current_room.look

          when "inventory"
            puts @player.show_inventory

          when /^take (.+)$/
            take_object($1)

          when /^drop (.+)$/
            drop_object($1)

          # EXTRA COMMANDS
          when "dirs" # get available directions
            puts @current_room.exits.keys.join(", ")

          else
            puts "Unknown command #{input}"
          end
        end
      else
        exit
      end
    end

    def take_object(name)
      puts @player << (@current_room >> Object.find(name, @objects))
    end

    def drop_object(name)
      @current_room << (@player >> Object.find(name, @objects))
    end
  end
end
