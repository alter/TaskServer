#!/usr/bin/env ruby
require "web_socket"
require 'yaml'

host = 'ws://127.0.0.1:50000/'

client = WebSocket.new(host)
puts("Connected")

task = {cmd:"push", arg:"test0"}
client.send(task.to_yaml)
task = {cmd:"push", arg:"test1"}
client.send(task.to_yaml)
task = {cmd:"push", arg:"test2"}
client.send(task.to_yaml)
task = {cmd:"list"}
client.send(task.to_yaml)


Thread.new() do
  while data = client.receive()
    printf("Client received: %p\n", data)
  end
  client.close()
  exit()
end

$stdin.each_line() do |line|
  data = line.chomp()
  client.send(data)
  printf("Client sent: %p\n", data)
end

client.close()
puts("Disconnected")
