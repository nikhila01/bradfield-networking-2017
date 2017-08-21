require 'socket'
require 'pry'

socket = UDPSocket.new(Socket::AF_INET)

client_address = '0.0.0.0'
client_rcv_port = 56949

puts ("This socket identified by: " + client_address + ":" + client_rcv_port.to_s)

puts 'Enter the ip address you wish to send to: '
server_ip = gets.chomp
puts ('Type the port number you wish to send to: ')
server_port = gets.chomp.to_i
puts('Enter the ip address to forward this message to: ')
forward_ip = gets.chomp
puts('Enter the port to be forwarded to: ')
forward_port = gets.chomp.to_i

while true do
  puts ('Enter a string to be echoed: ')
  message = gets.chomp
  final_message = "#{message}, #{forward_ip}, #{forward_port}"
  socket.send(final_message, 0, server_ip, server_port)
  puts("sent: " + final_message.to_s)
end