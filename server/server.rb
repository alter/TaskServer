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

def send_data(socket, data)
  packed_data = YAML.dump(data)
  socket.write([packed_data.length].pack("I"))
  socket.write(packed_data)
end

def read_data(socket)
  length = socket.read(4).unpack("I")[0]
  YAML.load(socket.read(length))
end

task = {id: 1, cmd:"push", arg:"test0"}
send_data(socket, task)
task = {id: 2, cmd:"push", arg:"test1"}
send_data(socket, task)
task = {id: 3, cmd:"push", arg:"test2"}
send_data(socket, task)
task = {id: 4, cmd:"push", arg:"test4"}
send_data(socket, task)
task = {cmd:"pop"}
send_data(socket, task)
task = {cmd:"list"}
send_data(socket, task)
task = {cmd:"size"}
send_data(socket, task)
task = {cmd:"quit"}
send_data(socket, task)

loop do
  p read_data(socket)
end

socket.close()