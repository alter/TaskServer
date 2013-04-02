#!/usr/bin/env ruby
# encoding: ASCII-8BIT

require 'thread'
require 'socket'
require 'net/telnet'
require 'json/pure'

PORT = 50000
HOST = '127.0.0.1'

client = Net::Telnet.new('Host'=>HOST, 'Port'=>PORT, "Prompt"=>/^\+OK/n)
#=begin
task = JSON.generate [{cmd:'push',id:1,arg:'test1'}]
client.cmd(task){ |str| puts str }
task = JSON.generate [{cmd:'push',id:2,arg:'test2'}]
client.cmd(task){ |str| puts str }
task = JSON.generate [{cmd:'push',id:3,arg:'test3'}]
client.cmd(task){ |str| puts str }

task = JSON.generate [{cmd:'list'}]
client.cmd(task){ |str| puts str }
task = JSON.generate [{cmd:'size'}]
client.cmd(task){ |str| puts str }
#=end
task = JSON.generate [{cmd:'status'}]

client.cmd(task){ |str| puts str }
task = JSON.generate [{cmd:'quit'}]
client.cmd(task){ |str| puts str }

client.close
Signal.trap("PIPE", "EXIT")