#!/usr/bin/env ruby

require 'bundler/setup'
require 'particle_pool'

load File.dirname(__FILE__) + '/task.rb'

t = gettask

t.start 10
until t.done? do
  t.resume
end