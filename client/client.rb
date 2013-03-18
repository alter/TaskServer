#!/usr/bin/env ruby
require "web_socket"

host = 'ws://127.0.0.1:50000/'

client = WebSocket.new(host)
puts("Connected")

client.send('push: task1')
client.send('push: task2')
client.send('list')
client.send('size')
client.send('push: task3')
client.send('pull')
client.send('list')
client.send('remove: 0')
client.send('list')


Thread.new() do
  while data = client.receive()
    printf("Client received: %p\n", data)
  end
  exit()
end

$stdin.each_line() do |line|
  data = line.chomp()
  client.send(data)
  printf("Client sent: %p\n", data)
end

client.close()
