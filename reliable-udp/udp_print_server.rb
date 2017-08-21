require 'socket'

hostname = '0.0.0.0'

server_port = 56948

socket = UDPSocket.new(Socket::AF_INET)


socket.bind(hostname, server_port)

puts("Listening on " + hostname + ":" + server_port.to_s)

while true do
  payload, client_address = socket.recvfrom(1024)
  puts "received payload: " +  payload.inspect

  sent = socket.send("ACK", 0, payload.split(',')[1].strip.to_s, payload.split(',')[2].strip.to_i)
end
