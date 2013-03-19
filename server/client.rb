#!/usr/bin/env ruby
require 'em-websocket'
require 'faye/websocket'
require 'eventmachine'
require 'yaml'

host = 'ws://127.0.0.1:50000/'

EM.run {
  ws = Faye::WebSocket::Client.new(host)

  ws.onopen = lambda do |event|
    p [:open]
    task = {cmd:"push", arg:"test0"}
    ws.send(task.to_yaml)
    task = {cmd:"push", arg:"test1"}
    ws.send(task.to_yaml)
    task = {cmd:"push", arg:"test2"}
    ws.send(task.to_yaml)
    task = {cmd:"list"}
    ws.send(task.to_yaml)
    task = {cmd:"size"}
    ws.send(task.to_yaml)
  end

  ws.onmessage = lambda do |event|
    p [:message, event.data]
  end

  ws.onclose = lambda do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
}

