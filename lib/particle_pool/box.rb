class ParticlePool::Box
  attr_accessor :value, :extra

  def initialize(value = nil)
    @value = value
    @extra = nil
  end

  def await(s=0.01)
    until @value
      Fiber.yield
      sleep(s)
    end
    @value
  end

  def await_sync(s=0.01)
    sleep(s) until @value
    @value
  end

  def await_for(v, s=0.01)
    until @value == v
      Fiber.yield
      sleep(s)
    end
    @value
  end

  def await_for_sync(v, s=0.01)
    sleep(s) until @value == v
    @value
  end

  def await_block(s=0.01, &b)
    until b.()
      Fiber.yield
      sleep(s)
    end
    @value
  end

  def await_block_sync(s=0.01, &b)
    sleep(s) until b.()
    @value
  end
end