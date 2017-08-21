require 'socket'

socket = UDPSocket.new(Socket::AF_INET)

server_address = '0.0.0.0'
puts "server port"
server_port = gets.chomp.to_i
puts "Type the fraction of datagrams that should be dropped: "
reliability = gets.chomp.to_f
puts "Type the fraction of datagrams that should be corrupted: "
corruption_rate = gets.chomp.to_f

socket.bind(server_address, server_port)

puts("This socket identified by: " + server_address + ":" + server_port.to_s)


while true do
  # ["uuuu", ["AF_INET", 33230, "localhost", "127.0.0.1"]]
  payload, client_info = socket.recvfrom(1024)
  puts "PAYLOAD: #{payload}"
  puts ("\n===New Packet===")
  if  rand(10) < reliability
    puts("  Dropped packet: {#{payload}")
    next
  end

#   try:
#     data, forwarding_address = ast.literal_eval(payload.decode('utf-8'))
#   print("  Received payload: ", str(payload))
#   print("  Forwarding data to " + str(forwarding_address))
#
#   if random.random() < corruption_rate:
#     corruption_index = random.randint(0, len(data) - 1)
#   corruption_bit_index = random.randint(0, len(data[corruption_index]) - 1)
#   new_character = chr(ord(data[corruption_index]) ^ (1 << corruption_bit_index))
#   corrupted_data = data[:corruption_index] + new_character + data[corruption_index+1:]
#   print("  Corruption event: {} became {}".format(data, corrupted_data))
#   data = corrupted_data
#   puts payload.split
#   puts payload.split(',')[1].to_s
#   puts payload.split(',')[2].to_i

  puts client_info.inspect
  forward_message = [ payload.split(',')[0], client_info[2], client_info[1]].join(',')

  sent = socket.send(forward_message, 0, payload.split(',')[1].strip.to_s, payload.split(',')[2].strip.to_i)
  puts sent
#   except:
#     print("  Failed to handle: {}".format(payload))
#   traceback.print_exc()
end

# check for corruption via checksum (could base64 or XOR message against itself)
# reliability via acknowledgement
# could use a unique id
# could use a finite state machine where does not send until receives back that got message

# how handle too large messages
