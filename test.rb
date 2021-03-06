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
    loopnum = 0
    until @socket.eof? do
      msg = @socket.gets
      puts msg
      loopnum +=1
      securenum =0
      if msg.match(/^PING :(.*)$/)
        say "PONG #{$~[1]}"
        next
      end

      if msg.match(/PRIVMSG ##{@channel} :(.*)$/)
        content = $~[1]
        if securenum != loopnum
          secure = true
        end
        if content.match("`")
          say_to_chan("I'm sorry Dave, I'm afraid I can't do that.")
          securenum = loopnum
          secure = false
        end
        if content.match("!do ") && secure
          msg.gsub!(/.*?(?=!do)/im, "")
          msg.slice!("!do ")
          say msg
        end
        if content.match("!action ") && secure
          msg.gsub!(/.*?(?=!action)/im, "")
          msg.slice!("!action ")
          
          say_to_chan("#{1.chr}ACTION "+msg+"#{1.chr}")
        end
        if content.match("!admin") && secure
          temp = msg
          temp.split("!admin")[0]
          #temp.slice!("!admin")
          if msg.start_with?(":Fabtasticwill!")
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
       # if msg.match("71.6.55.146")
        #  say_to_chan("Whats up, rainfvr?")
       # end
        if content.match("!ruby ") && secure
          $SAFE = 2
          msg.untaint
          if !content.match("say")
            msg.gsub!(/.*?(?=!ruby)/im, "")
            msg.slice!("!ruby ")
            begin
              say_to_chan(eval(msg).to_s)
            rescue Exception => exc
              say_to_chan(exc)
            end
          else
            if msg.start_with?(":Fabtasticwill!")
              msg.gsub!(/.*?(?=!ruby)/im, "")
              msg.slice!("!ruby ")
              begin
                say_to_chan(eval(msg).to_s)
              rescue Exception => exc
                say_to_chan(exc)
              end
            else
              say_to_chan ("I'm sorry Dave, I'm afraid I can't do that.");
            end
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