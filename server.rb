require "socket"
class Server
  
  def initialize ip, port
    @server = TCPServer.open(ip, port)
    @connections = Hash.new
    @rooms = Hash.new
    @clients = Hash.new
    @connections[:rooms] = @rooms
    @connections[:server] = @server
    @connections[:clients] = @clients
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do |client|
        nick_name = client.gets.chomp.to_sym
        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts "username already exists"
            Thread.kill self
          end
        end
        puts "#{nick_name} #{client}"
        @connections[:clients][nick_name] = client
        client.puts "connection established Happy chatting"
        listen_user_messages(nick_name, client)
      end
    }
  end

  def listen_user_messages username, client
    loop {
      msg = client.gets.chomp
      @connections[:clients].each do |other_name, other_client|
        unless other_name == username
          other_client.puts "#{username} #{msg}"
        end
      end
    }
  end
end

server = Server.new("localhost", 3000)
