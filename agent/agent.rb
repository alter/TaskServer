#!/usr/bin/env ruby
# encoding: ASCII-8BIT

require_relative '../library/tqueue.rb'
require 'yaml'
require 'thread'
require 'logger'
require 'socket'
require 'open3'
require 'gserver'

ADDR = '0.0.0.0'
PORT = 50000
$DEBUG = true

class Agent < GServer
  Thread.abort_on_exception = $DEBUG

  if $DEBUG
    PROGRAM_PATH = "sleep 5 && ls -a /tmp"
  else
    PROGRAM_PATH = "/home/a1/GPT_launcher/launcher.py"
  end

  $queue = Queue.new
  $tqueue = TQueue.new
  $thread = nil

  attr_accessor :log
  def initialize(port=PORT,host=ADDR, *args)
    super(port, host, *args)
    @log = Logger.new('./agent.log')
    @log.info "***********************************************"
    @log.info "* Agent has been started at #{host}:#{port} *"
    @log.info "***********************************************"
  end
  
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


  def runner
    if $tqueue.size != 0
      id, arg = $tqueue.pop
      #stdin, stdout, stderr = Open3.popen3("#{PROGRAM_PATH}/#{arg}")
      stdout, stderr, status = Open3.capture3("#{PROGRAM_PATH}/#{arg}")
      puts stdout
      if status.success?
        puts "It's success !!"
      end
      @log.info "running task with id = #{id} and arg = #{arg}"
      @log.error "stderr: #{stderr}"
      $queue.push({id:id,stderr:stderr,success:status.success?,status:status})
    else
        return 1
    end
  end

  def serve(session)

    session.print "Welcome to agent\r\n"

    loop do
      port = session.peeraddr[1]
      ip = session.peeraddr[2]
      @log.info "Receiving connection from #{ip}:#{port}"
      begin
        while unpacked_data = read_data(session)
          if unpacked_data.is_a?Hash
            unpacked_data.each{ |key,value|

              if key == :cmd && value == "push"
                @log.info ":cmd='#{value}' :arg='#{unpacked_data[:arg]}'"
                $tqueue.push(unpacked_data[:id], unpacked_data[:arg])

              elsif key == :cmd && value == 'remove'
                @log.info ":cmd='#{value}' :arg='#{unpacked_data[:arg]}'"
                $tqueue.remove(unpacked_data[:arg])

              elsif key == :cmd && value == "list"
                @log.info ":cmd='#{value}' :arg='#{unpacked_data[:arg]}'" if $DEBUG
                send_data(session, $tqueue.list)

              elsif key == :cmd && value == "size"
                @log.info ":cmd='#{value}' :arg='#{unpacked_data[:arg]}'" if $DEBUG
                send_data(session, $tqueue.size)

              elsif key == :cmd && value == "status"
                while (task = $queue.shift(true) rescue nil) do
                  send_data(session, task)
                end

              elsif key == :cmd && value == "quit"
                @log.info ":cmd='#{value}' :arg='#{unpacked_data[:arg]}'" if $DEBUG
                session.close
              end
            }
            if $thread == nil or !$thread.alive?
              run_tasks.call
            end
          end
        end
      end
    end
  end
end

agent = Agent.new(PORT,ADDR)
#agent.audit = true
agent.start
agent.join