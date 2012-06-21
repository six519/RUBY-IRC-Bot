=begin
* A Simple IRC Bot
* @author Ferdinand E. Silva (ferdinandsilva@ferdinandsilva.com)
* @version Version 1.0
* THIS IS MY FIRST RUBY CODING ATTEMPT!!!!!!
=end

require 'socket'

class RubyIRC

	def initialize()
		@ircServer = ""
		@ircPort = 6667
		@ircNick = ""
		@ircRoom = ""
		@socket = nil
		main
	end
	
	def main()
		@ircServer = getUserInput "Please Enter IRC Server Address:"
		@ircNick = getUserInput "Please Enter IRC Nick"
		@ircRoom = getUserInput "Please Enter IRC Channel"
		connect
	end
	
	def getUserInput(msg)
		endInput = false
		strInput = ""
		
		while !endInput
			puts msg
			strInput = gets.strip
			
			if not strInput.empty?
				return strInput
			end
			
		end
	end
	
	def connect()
		begin
			@socket = TCPSocket.open(@ircServer, @ircPort)
			receiveMessages
		rescue SocketError
			@socket = nil
			
			if getUserInput("Restart Application? Enter y to restart") == "y"
				main
			end
		end
	end
	
	def receiveMessages()
		while buffer = @socket.gets
			puts buffer.chop
			
			if buffer =~ /Checking Ident/i
				sendMessage "NICK " << @ircNick
				sendMessage "USER " << @ircNick << " \"" << @ircNick << ".com\" \"" << @ircServer << "\" : " << @ircNick << " robot"
			elsif buffer =~ /End of \/MOTD command/i
				sendMessage "JOIN #" << @ircRoom
			elsif buffer =~ /PING :/i
				sendMessage buffer.sub!(/PING/,"PONG")
			elsif buffer =~ Regexp.new("JOIN \#" << @ircRoom)
				if @ircNick != extractNick(buffer)
					#Auto Greeter
					sendMessage "PRIVMSG #" << @ircRoom << " :Hi " << extractNick(buffer) << "!"
				end
			end
			
			#ADD command handler below the auto greeter line (another elsif)
		end	
	end
	
	def sendMessage(msg)
		@socket.puts msg << "\r\n"
	end
	
	def extractNick(str)
		tmpStr = str.split ":"
		tmpStr = tmpStr[1].split "!"
		
		return tmpStr[0]
	end

end

begin
	bot = RubyIRC.new
rescue Interrupt
	puts "\nApplication quits...."
	exit(0)
end
