#!/usr/bin/env ruby

queue = TQueue.new
queue.push('test1')
queue.push('test2')
queue.push('test3')
queue.push('test4')
queue.push('test5')

p queue.list
p queue.size
queue.remove(2)
p queue.list
p queue.size
queue.remove(0)
p queue.list
p queue.size
queue.pull
p queue.list
p queue.size

