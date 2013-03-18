#!/usr/bin/env ruby
require "web_socket"
require 'yaml'

host = 'ws://127.0.0.1:50000/'

client = WebSocket.new(host)
puts("Connected")

task = [{push:"task1"}]
client.send(task.to_yaml)
task = [{push:"task2"}]
client.send(task.to_yaml)
task = [{push:"task3"}]
client.send(task.to_yaml)
task = ['list']
client.send(task.to_yaml)


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
puts("Disconnected")
