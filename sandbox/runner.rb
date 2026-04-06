# Runs player-submitted code in the context of dont.rb.
#
# __FILE__ is spoofed to /game/dont.rb so File.read(__FILE__) and
# File.write(__FILE__, ...) behave as the player expects.
#
# exec() is overridden to exit with code 42, which the game server
# interprets as "the script called exec — start a new iteration."

module Kernel
  def exec(*args)
    exit(42)
  end
end

begin
  player_code = File.read('/game/player_code.rb')
  eval(player_code, binding, '/game/dont.rb', 1)
rescue SystemExit => e
  exit(e.status)
rescue Exception => e
  STDERR.puts "#{e.class}: #{e.message}"
  e.backtrace&.first(5)&.each { |line| STDERR.puts "  #{line}" }
  exit(1)
end
