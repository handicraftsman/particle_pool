#!/usr/bin/env ruby

require 'bundler/setup'
require 'particle_pool'

load File.dirname(__FILE__) + '/task.rb'

pt = ParticlePool::PoolThread.new

64.times do |i|
  t = gettask

  pt.push(t, i)
end

Thread.new do  
  pt.start
end

loop do
  sleep 1
end