require 'socket' 
require_relative 'sandbox'

class SimpleIrcBot
  def initialize(server, port, channel)
    @channel = channel
    @socket = TCPSocket.open(server, port)
    say "NICK WillBot"
    say "USER willbot 0 * WillBot"
    say "JOIN ##{@channel}"
    say_to_chan "#{1.chr}ACTION is here to help#{1.chr}"
  end

  def say(msg)
    puts msg
    @socket.puts msg
  end

  def say_to_chan(msg)
    say "PRIVMSG ##{@channel} :#{msg}"
  end

  def run
    until @socket.eof? do
      msg = @socket.gets
      puts msg

      if msg.match(/^PING :(.*)$/)
        say "PONG #{$~[1]}"
        next
      end

      if msg.match(/PRIVMSG ##{@channel} :(.*)$/)
        content = $~[1]
        if content.match("`")
          say_to_chan("I'm sorry Dave, I'm afraid I can't do that.")
        end
        elsif content.match("!do ")
          msg.gsub!(/.*?(?=!do)/im, "")
          msg.slice!("!do ")
          say msg
        end
        elsif content.match("!admin")
          temp = msg
          temp.split("!admin")[0]
          #temp.slice!("!admin")
          if msg.match("Fabtasticwill")
            if content.match("exit")
              say_to_chan("#{1.chr}ACTION is exiting...#{1.chr}")
              say "EXIT"
              abort("Exiting")
            end
          else
            say_to_chan("I'm sorry Dave, I'm afraid I can't do that.");
          end
          #end
        end
        elsif content.match("!ruby ")
          msg.gsub!(/.*?(?=!ruby)/im, "")
          msg.slice!("!ruby ")
          #say_to_chan(msg)
            #say_to_chan("I'm sorry Bill, I'm afraid I can't let you do that.")
          begin
            say_to_chan(eval(msg).to_s)
          rescue Exception => exc
            say_to_chan(exc)
          end 
        end
      end
    end
  end
  def quit
    say "PART ##{@channel} :message"
    say 'QUIT'
  end
end

bot = SimpleIrcBot.new("irc.ubuntu.com", 6667, 'cplusplus.com')

trap("INT"){ bot.quit }

bot.run