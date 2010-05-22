module InteractiveFiction
  class World
    INPUT_SEPARATOR = " "
    MOVES = %w[north east south west]
    QUIT = %w[q quit]
    attr_reader :rooms, :objects, :actions, :synonyms, :current_room
    def initialize(objects, input, output)
      @input, @output = input, output

      objects.group_by(&:class).each_pair { |klass, value|
        name = klass.simple_name.downcase.end_with!("s")
        instance_variable_set "@#{name}", value
      }

      @player = Player.new(self)

      @rooms.each { |room| room.world = self }

      change_room @rooms.first
    end

    def start!
      @output.puts @current_room.long_description
    end

    def change_room(room)
      @current_room = room
      room.enter
    end

    def enter_room(room)
      room = Room.find(room, @rooms)
      @output.puts room.description
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
            @output.puts message
          when String
            enter_room dir
          end

        elsif MOVES.include? input
          @output.puts "There is no way to go in that direction"

        elsif action = Action.find(input, @actions)
          message, blackboard = @player.instance_eval(action.code) # [MESSAGE, BLACKBOARD]
          @output.puts message
          @player.blackboard.merge!(blackboard)

        else
          case input
          when "look"
            @output.puts @current_room.look

          when "inventory"
            @output.puts @player.show_inventory

          when /^take (.+)$/
            take_object($1)

          when /^drop (.+)$/
            drop_object($1)

          # EXTRA COMMANDS
          when "dirs" # get available directions
            @output.puts @current_room.exits.keys.join(", ")

          else
            @output.puts "Unknown command #{input}"
          end
        end
      else
        exit
      end
    end

    def take_object(name)
      @output.puts @player << (@current_room >> Object.find(name, @objects))
    end

    def drop_object(name)
      @current_room << (@player >> Object.find(name, @objects))
    end
  end
end
