def gettask
  ParticlePool::Task.new do |n|
    raise 'fib not defined for negative numbers' if n < 0
    nv, ov = 1, 0
    n.times do
      nv, ov = nv + ov, nv
      Fiber.yield
    end
    puts "fib(#{n}) == #{ov}"
    ov
  end
end