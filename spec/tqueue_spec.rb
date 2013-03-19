#!/usr/bin/env ruby
require 'spec_helper'
describe TQueue do
  before :all do
      @queue = TQueue.new    
  end
  
  it "should add 5 tasks to queue" do
    @queue.push('test1')
    @queue.push('test2')
    @queue.push('test3')
    @queue.push('test4')
    @queue.push('test5')
    list = @queue.list
    puts "task list: #{list}"
  end
  
  it "should remove task with index 2 and return size of queue" do
    size = @queue.remove(2)
    puts "queue size: #{size}"
  end
  
  it "should take task from queue" do
    current_task = @queue.pop
    puts "current task: #{current_task}"
  end
  
  it "should show list of tasks in queue" do
    list = @queue.list
    puts "task list: #{list}"
  end
  
  it "should show size of queue" do
    size = @queue.size
    puts "queue size: #{size}"
  end
end
