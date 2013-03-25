#!/usr/bin/env ruby
# encoding: ASCII-8BIT

require 'yaml'
require 'thread'
require 'socket'
require 'logger'

PORT = 50000
ARRD = '127.0.0.1'

socket = TCPSocket.new(ARRD, PORT)
socket.set_encoding 'ASCII-8BIT'

task = {cmd:"push", arg:"test0"}
socket.puts(task.to_yaml)
task = {cmd:"push", arg:"test1"}
socket.puts(task.to_yaml)
task = {cmd:"push", arg:"test2"}
socket.puts(task.to_yaml)
task = {cmd:"list"}
socket.puts(task.to_yaml)
task = {cmd:"size"}
socket.puts(task.to_yaml)

while unpacked_data = YAML::load(socket.gets())
  puts unpacked_data
end
