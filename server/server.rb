#!/usr/bin/env ruby
require_relative '../library/tqueue.rb'
require 'web_socket'

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
    while data = ws.receive()
      if match = data.match(push_regex)
        task = match.captures.first
        queue.push(task)
      elsif match = data.match(list_regex)
        ws.send(queue.list)
      elsif match = data.match(pull_regex)
        ws.send(queue.pull)
      elsif match = data.match(remove_regex)
        task = match.captures.first.to_s
        ws.send(queue.remove(task))
      elsif match = data.match(size_regex)
        ws.send(queue.size.to_s)
      end
      puts "Current queue list: #{queue.list}"
      printf("Server receive: %p\n", data)
    end
  else
    ws.handshake("404 Not Found")
  end
  puts("Connection closed")
end
