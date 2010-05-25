if RUBY_VERSION < "1.9.2"
  # Backports: http://github.com/marcandre/backports
  begin
    # Gem load
    require 'rubygems'
    require 'backports/1.9'
  rescue LoadError
    puts $!
    puts "You need to install backports(http://github.com/marcandre/backports) `gem install backports`"
    puts "Notice: this cannot be considered as an external gem to help the challenge, it's just there to fill the gap between ruby versions ;)"
  end
end

if __FILE__ == $0
  Dir[File.join(File.dirname(__FILE__), "*.rb")].each { |f|
    require f unless f == __FILE__
  }
  puts InteractiveFiction::Parser.new(File.expand_path("../../data/petite_cave.if", __FILE__)).parse
end
