#!/usr/bin/env ruby

require 'bundler/setup'
require 'particle_pool'

load File.dirname(__FILE__) + '/task.rb'

p = ParticlePool::Pool.new
p.start

$sz = 0
$arr = []

(1024 * Etc.nprocessors).times do |i|
  t = ParticlePool::Task.new do |n|
    raise 'fib not defined for negative numbers' if n < 0
    nv, ov = 1, 0
    n.times do
      nv, ov = nv + ov, nv
      Fiber.yield
    end
    $arr << ov
    $sz += 1
    ov
  end

  p.push(t, i)
end

t = ParticlePool::Task.new do
  sleep 16
  'Hello, World!'
end
p.push(t)

puts t.await_sync

while $sz != (1024 * Etc.nprocessors) do
  sleep 1
end

puts $arr.reduce(:+)