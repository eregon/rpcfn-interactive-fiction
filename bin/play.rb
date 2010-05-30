#!/usr/bin/env ruby
require File.expand_path("../../lib/main", __FILE__)

module InteractiveFiction
  class Game
    def initialize(story_path, options={})
      @input  = options.fetch(:input)  { $stdin  }
      @output = options.fetch(:output) { $stdout }

      objects = Parser.new(story_path).parse
      @world = World.new(objects, @input, @output)

      # The tests keep ~182000 objects! (on 390660 total)
      # This can be reduced to ~140000 objects by adding "@description = nil"
      # at the end of the constructor of every AbstractObject's subclass
      # This is, however, slower due to GC

      # GC.start
      # p ObjectSpace.each_object {}
    end

    def play!
      start!
      execute_one_command! until ended?
    end

    def start!
      @world.start!
    end

    def execute_one_command!
      print "> " if __FILE__ == $0
      @world.execute_one_command!
    end

    def ended?
      false # The game never ends :)
    end
  end
end

Game = InteractiveFiction::Game

if $0 == __FILE__
  story_path = ARGV[0] || File.expand_path("../../data/petite_cave.if", __FILE__)
  unless story_path
    warn "Usage: #{$0} STORY_FILE"
    exit 1
  end
  game = Game.new(story_path)
  game.play!
end
