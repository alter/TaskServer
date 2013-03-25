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
  
server = TCPServer.new(ADDR, PORT)
log = Logger.new('./server.log')

log.info "***********************************************"
log.info "* Logserver has been started at #{ADDR}:#{PORT}* "
log.info "***********************************************"

loop do
  socket = server.accept
  socket.set_encoding 'ASCII-8BIT'
  Thread.start do
    port = socket.peeraddr[1]
    name = socket.peeraddr[2]

    log.info "Recieving connection from #{name}:#{port}"
      begin
        while unpacked_data = YAML::load(socket.gets)
          puts unpacked_data if $DEBUG == true
          log.info "Recieving #{unpacked_data} from #{name}:#{port}"
          if unpacked_data.is_a?Hash
            unpacked_data.each{ |key,value|
              puts "key: #{key} | value: #{value}" if $DEBUG == true
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
            }
          end
        end
        rescue ClientQuitError
          log.error "*** #{name}:#{port} disconnected"
        ensure 
          socket.close()
      end    
  end
end