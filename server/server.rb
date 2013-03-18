#!/usr/bin/env ruby
require_relative '../library/tqueue.rb'
require 'web_socket'
require 'yaml'

Thread.abort_on_exception = true
#WebSocket.debug = true

queue = TQueue.new

localhost = '127.0.0.1'
port = 50000

server = WebSocketServer.new(
  :accepted_domains => [localhost],
  :port => port.to_i()
  )
 
push_regex    = Regexp.compile('^push:\s?(.*)$')
list_regex    = Regexp.compile('^list$')
pull_regex    = Regexp.compile('^pull$')
remove_regex  = Regexp.compile('^remove:\s?([0-9]{1,5})$')
size_regex    = Regexp.compile('^size$')

puts("Server is running at port %d" % server.port)
server.run() do |ws|
  puts("Connection accepted")
  puts("Path: #{ws.path}, Origin: #{ws.origin}")
  if ws.path == "/"
    ws.handshake()
    while data = YAML::load(ws.receive())
      unpacked_data = data[0]
      if unpacked_data.is_a?Hash
        unpacked_data.each{|key,value|
          if key == 'push'
            queue.push(value)
          elsif key == 'remove'
            queue.remove(value)
          end  
        }
      elsif unpacked_data.is_a?String
        if unpacked_data == 'list'
          ws.send(queue.list)
        elsif unpacked_data == 'pull' 
          ws.send(queue.pull)
        elsif unpacked_data == 'size' 
          ws.send(queue.size.to_s)
        end
      end
      puts "Current queue list: #{queue.list}"
      printf("Server receive: %p\n", data)
    end
  else
    ws.handshake("404 Not Found")
  end
  puts("Connection closed")
end
