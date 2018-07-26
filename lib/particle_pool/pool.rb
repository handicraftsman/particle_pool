class ParticlePool::Pool
  def initialize
    @threads = []
  end

  def <<(t, *args, **kwargs)
    push(t, *args, **kwargs)
  end

  def push(t, *args, **kwargs)
    thr = @threads.min
    raise 'no threads available' unless t
    thr.push(t, *args, **kwargs)
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