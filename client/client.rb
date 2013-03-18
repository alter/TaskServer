#!/usr/bin/env ruby
require "socket"
require 'libwebsocket'

class WSocket
  def initialize(url, params = {})
    @hs ||= LibWebSocket::OpeningHandshake::Client.new(:url => url,
        :version => params[:version])
    @frame ||= LibWebSocket::Frame.new

    @socket = TCPSocket.new(@hs.url.host, @hs.url.port || 8080)

    @socket.write(@hs.to_s)
    @socket.flush

    loop do
      data = @socket.getc
      next if data.nil?

      result = @hs.parse(data.chr)
      raise @hs.error unless result

      if @hs.done?
        @handshaked = true
        break
      end
    end
  end

  def send(data)
    raise "no handshake!" unless @handshaked

    data = @frame.new(data).to_s
    @socket.write data
    @socket.flush
  end

  def receive
    raise "no handshake!" unless @handshaked

    data = @socket.gets("\xff")
    @frame.append(data)

    messages = []
    while message = @frame.next
      messages << message
    end
    messages
  end
end

ws = WSocket.new('ws://127.0.0.1:8080')
ws.send('test')
puts ws.receive

