#!/usr/bin/env ruby
# encoding: ASCII-8BIT

require 'yaml'
require 'thread'
require 'socket'
require 'logger'

PORT = 50000
ARRD = '127.0.0.1'

socket = TCPSocket.new(ARRD, PORT)

def send_data(socket, data)
  packed_data = YAML.dump(data)
  socket.write([packed_data.length].pack("I"))
  socket.write(packed_data)
end

def read_data(socket)
  chunk = socket.read(4)
  if chunk.nil?
    return 1
  else
    length = chunk.unpack("I")[0]
    data = socket.read(length)
    data && (YAML.load(data))
  end
end


task = {id: 1, cmd:"push", arg:"test5"}
send_data(socket, task)

task = {id: 2, cmd:"push", arg:"test6"}
send_data(socket, task)

task = {id: 3, cmd:"push", arg:"test7"}
send_data(socket, task)

task = {id: 4, cmd:"push", arg:"test8"}
send_data(socket, task)

task = {cmd:"pop"}
send_data(socket, task)

task = {cmd:"list"}
send_data(socket, task)

task = {cmd:"size"}
send_data(socket, task)

task = {cmd: "status"}
send_data(socket,task)

begin
  data = read_data(socket)
  p data
end until data != 1

ap "Cicle"