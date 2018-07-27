#!/usr/bin/env ruby

require 'bundler/setup'
require 'particle_pool'

load File.dirname(__FILE__) + '/task.rb'

p = ParticlePool::Pool.new
p.start 16

Result = Struct.new(:sz, :arr)
Sum = Struct.new(:sz, :sum)

res = Result.new
res.sz = 0
res.arr = []

resbox = ParticlePool::Box.new res

2048.times do |i|
  t = ParticlePool::Task.new do |n|
    raise 'fib not defined for negative numbers' if n < 0
    nv, ov = 1, 0
    n.times do
      nv, ov = nv + ov, nv
      Fiber.yield
    end
    res.arr << ov
    res.sz += 1
    ov
  end

  p.push(t, i)
end

t = ParticlePool::Task.new do
  sleep 16
  'Hello, World!'
end
p.push(t)

t2 = ParticlePool::Task.new do
  puts t.await
end
p.push(t2)

abox = ParticlePool::Box.new
t3 = ParticlePool::Task.new do
  sleep 20
  abox.value = 'asdf'
end
p.push(t3)

t4 = ParticlePool::Task.new do
  puts abox.await
end
p.push(t4)

sum     = Sum.new
sum.sz  = 0
sum.sum = 0
sumbox  = ParticlePool::Box.new sum

tres = ParticlePool::Task.new do
  resbox.await_block do
    resbox.value.sz == 2048
  end

  resbox.value.arr.each do |i|
    t = ParticlePool::Task.new do
      sumbox.value.sz += 1
      sumbox.value.sum += i
    end
    p.push(t)
  end

  sumbox.await_block do
    sumbox.value.sz == 2048
  end

  puts sumbox.value.sum
end
p.push(tres)

while sumbox.value.sz != 2048 do
  sleep 1
end
sleep 2