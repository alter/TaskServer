#!/usr/bin/env ruby
# encoding: ASCII-8BIT

require_relative '../library/tqueue.rb'
require 'yaml'
require 'thread'
require 'logger'
require 'socket'

$DEBUG = true
Thread.abort_on_exception = $DEBUG
ADDR = '0.0.0.0'
PORT = 50000
PROGRAM_PATH = "/home/a1/GPT_launcher/launcher.py"
tqueue = TQueue.new
  
def send_data(socket, data)
  packed_data = YAML.dump(data)
  socket.write([packed_data.length].pack("I"))
  socket.write(packed_data)
end

def read_data(socket)
  length = socket.read(4).unpack("I")[0]
  YAML.load(socket.read(length))
end
server = TCPServer.new(ADDR, PORT)

log = Logger.new('./agent.log')
log.info "***********************************************"
log.info "* Logserver has been started at #{ADDR}:#{PORT} *"
log.info "***********************************************"

loop do
  socket = server.accept
  socket.set_encoding 'ASCII-8BIT'
  Thread.start do
    port = socket.peeraddr[1]
    ip = socket.peeraddr[2]
    log.info "Recieving connection from #{ip}:#{port}"
    begin
      while unpacked_data = read_data(socket)
        if unpacked_data.is_a?Hash
          unpacked_data.each{ |key,value|
            if key == :cmd && value == "push"
              log.info ":cmd='push' :arg='#{unpacked_data[:arg]}'"
              tqueue.push(unpacked_data[:arg])
            elsif key == :cmd && value == 'remove'
              log.info ":cmd='remove' :arg='#{unpacked_data[:arg]}'"
              tqueue.remove(unpacked_data[:arg])
            elsif key == :cmd && value == "list"
              send_data(socket, tqueue.list)
            elsif key == :cmd && value == "pop"
              send_data(socket, tqueue.pop)
            elsif key == :cmd && value == "size"
              send_data(socket, tqueue.size)
            end
          }
        end
      end
    rescue ClientQuitError
      log.error "Client #{ip}:#{port} has been disconnected with error"
    ensure 
      socket.close()
      log.info "Client #{ip}:#{port} has been disconnected"
    end
  end
end

=begin
             if unpacked_data.is_a?Hash
              unpacked_data.each{ |key,value|
            #    puts "key: #{key} | value: #{value}" if $DEBUG == true
                if key == :cmd && value == "push"
                  puts "Argument: #{unpacked_data[:arg]}" if $DEBUG == true
                  tqueue.push(unpacked_data[:arg])
                elsif key == :cmd && value == 'remove'
                  tqueue.remove(unpacked_data[:arg])
                elsif key == :cmd && value == "list"
                  socket.puts(tqueue.list.to_yaml)
                elsif key == :cmd && value == "pop"
                  socket.puts(tqueue.pop.to_yaml)
                elsif key == :cmd && value == "size"
                  socket.puts(tqueue.size.to_yaml)
                end  
=end 