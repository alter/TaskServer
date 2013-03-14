#!/usr/bin/env ruby

dirname = File.basename(Dir.getwd)
p dirname
require "#{dirname}../library/tqueue.rb"

queue = TQueue.new