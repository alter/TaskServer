#!/usr/bin/env ruby
require_relative '../library/tqueue.rb'
require 'web_socket'
require 'yaml'

Thread.abort_on_exception = true
#WebSocket.debug = true
DEBUG = true

tqueue = TQueue.new
queue = Queue.new

localhost = '127.0.0.1'
port = 50000

server = WebSocketServer.new(
  :accepted_domains => [localhost],
  :port => port.to_i()
  )
 
push_regex    = Regexp.compile('^push:\s?(.*)$')
list_regex    = Regexp.compile('^list$')
pop_regex    = Regexp.compile('^pop$')
remove_regex  = Regexp.compile('^remove:\s?([0-9]{1,5})$')
size_regex    = Regexp.compile('^size$')

puts("Server is running at port %d" % server.port)
server.run() do |ws|
  puts("Connection accepted")
  puts("Path: #{ws.path}, Origin: #{ws.origin}")
  if ws.path == "/"
    ws.handshake()
    while data = YAML::load(ws.receive())
      if data.is_a?Hash
        data.each{|key,value|
          puts "#{key} === #{value}" if DEBUG == true
          if key == :cmd && value == "push"
            puts "data: #{data[:arg]}" if DEBUG == true
            tqueue.push(data[:arg])
          elsif key == :cmd && value == 'remove'
            tqueue.remove(data[:arg])
          elsif key == :cmd && value == "list"
            ws.send(tqueue.list)
          elsif key == :cmd && value == "pop"
            ws.send(tqueue.pop)
          elsif key == :cmd && value == "size"
            ws.send(tqueue.size.to_s)
          end  
        }
      puts "Current tqueue list: #{tqueue.list}" if DEBUG == true
      printf("Server receive: %p\n", data) if DEBUG == true
      end
    end
  else
    ws.handshake("404 Not Found")
  end
  puts("Connection closed")
end
