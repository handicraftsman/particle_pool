class ParticlePool::Task
  attr_reader :value, :status

  module Status
    NOT_STARTED = 0
    ALIVE = 1
    DEAD = 2
    PAUSED = 3
  end

  def initialize(&b)
    @value = nil
    @status = Status::NOT_STARTED
    @b = b
  end

  def start(*params)
    raise 'cannot start already started task' if @status != Status::NOT_STARTED
    @f = Fiber.new do |*params|
      @status = Status::ALIVE
      @b.(*params)
    end
    @value = @f.resume(*params)
    _upd()
    @status
  end

  def resume
    if @status == Status::PAUSED
      @status = Status::ALIVE
      @value = @f.resume(@value)
    end
    _upd()
    @status
  end

  def alive?
    @f.alive?
  end

  def done?
    @status == Status::DEAD
  end

  def await(s=0.01)
    sleep(s) until done?
    @value
  end

  def _upd
    if alive?
      @status = Status::PAUSED
    else
      @status = Status::DEAD
    end
  end

end