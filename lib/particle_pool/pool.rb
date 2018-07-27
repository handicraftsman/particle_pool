class ParticlePool::Pool
  def initialize
    @mtx         = Mutex.new
    @threads     = []
    @round_robin = false
    @iter        = @threads.each
  end

  def <<(t, *args, **kwargs)
    push(t, *args, **kwargs)
  end

  def push(t, *args, **kwargs)
    @mtx.synchronize do
      thr = @threads.min
      raise 'no threads available' unless t
      thr.push(t, *args, **kwargs)
    end
  end

  def start(size = Etc.nprocessors)
    size.times do
      @threads << ParticlePool::PoolThread.new
    end
    @threads.each do |t|
      Thread.new do
        t.start
      end
    end
  end
end