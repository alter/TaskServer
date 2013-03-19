#!/usr/bin/env ruby
require_relative '../library/tqueue.rb'
require 'em-websocket'
require 'yaml'
require 'thread'

$DEBUG = true

Thread.abort_on_exception = $DEBUG

tqueue = TQueue.new
queue = Queue.new

EM.run {
  EM::WebSocket.run(:host => "0.0.0.0", :port => 50000) do |ws|
    ws.onopen { |handshake|
      puts "WebSocket connection open"

      # Access properties on the EM::WebSocket::Handshake object, e.g.
      # path, query_string, origin, headers

      # Publish message to the client
      ws.send "Hello Client, you connected to #{handshake.path}"
    }

    ws.onclose { puts "Connection closed" }
    ws.onmessage { |data|
      while data = YAML::load(ws.receive())
        if data.is_a?Hash
          data.each{ |key,value|
            puts "key: #{key} | value: #{value}" if $DEBUG == true
            if key == :cmd && value == "push"
              puts "Argument: #{data[:arg]}" if $DEBUG == true
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
        puts "Current tqueue list: #{tqueue.list}" if $DEBUG == true
        puts "Current tqueue size: #{tqueue.size}" if $DEBUG == true
        printf("Server receive: %p\n", data) if $DEBUG == true
        end
      end
    }
  end
}