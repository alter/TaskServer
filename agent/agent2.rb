#!/usr/bin/env ruby
# encoding: ASCII-8BIT

require_relative '../library/tqueue.rb'
require 'thread'
require 'logger'
require 'socket'
require 'open3'
require 'gserver'
require 'json/pure'

PORT=50000
HOST='0.0.0.0'

class Agent < GServer
  attr_accessor :queue
  attr_accessor :tqueue
  attr_accessor :log
  attr_accessor :cmd
  attr_accessor :id
  attr_accessor :arg
  attr_accessor :thread

  def initialize(port,host,*args)
    super(port,host,*args)
    @queue = Queue.new
    @tqueue = TQueue.new
    @log = Logger.new('./agent.log')
    @log.info "Agent has been started at #{host}:#{port}"
  end

  def runner
    if @tqueue.size != 0
      id, arg = @tqueue.pop
      stdout, stderr, status = Open3.capture3("#{PROGRAM_PATH}/#{arg}")
      @log.info "Task with id = #{id} and arg = #{arg} is starting"
      @log.error "stderr: #{stderr}"
      @queue.push({id:id,stderr:stderr,success:status.success?,status:status})
    else
      return 1
    end
  end

  def serve(session)
    run_tasks = proc {
      @thread = Thread.new {
        begin
          flag = runner
        end until flag != 1
      }
      @thread.join
    }

    session.puts "Welcome to server\r\n"
    loop{
      json = JSON.parse *session.gets.chomp.split
      @log.info "Aget has got json: '#{json}'"
      @cmd = json[0]['cmd']
      @id  = json[0]['id']
      @arg = json[0]['arg']

      case @cmd
        when "push"
          begin
            session.puts "Task #{@arg} has been added to TQueue \r\n"
            @tqueue.push(@id, @arg)
          end
        when "remove"
          begin
            @tqueue.remove(@arg)
            session.puts "Task #{@arg} has been removed from TQueue \r\n"
          rescue
            session.puts "No such task(#{ @arg.inspect }) in TQueue \r\n"
          end
        when "list"
          begin
            session.puts @tqueue.list
          end
        when "size"
          begin
            session.puts @tqueue.size
          end
        when "status"
          begin
            while (task = @queue.shift(true) rescue nil) do
              session.puts "#{task} \r\n"
            end
          end
        when "quit"
          session.puts "+OK"
          session.close
          break
        else
          session.puts "Bad command!\r\n"
      end
      if @thread == nil or !@thread.alive?
        run_tasks.call
      end
      session.puts "+OK"
    }
  end
end

agent = Agent.new(PORT,HOST)
agent.start
agent.join
