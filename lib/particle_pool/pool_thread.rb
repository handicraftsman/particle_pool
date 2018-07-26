class ParticlePool::PoolThread
  include Comparable

  attr_reader :tasks

  def initialize
    @queue = Queue.new
    @tasks = 0
  end

  def <<(t, *args, **kwargs)
    push(t, *args, **kwargs)
  end

  def push(t, *args, **kwargs)
    @tasks += 1
    @queue << {
      task: t,
      args: args,
      kwargs: kwargs
    }
  end

  def <=>(other)
    self.tasks <=> other.tasks
  end

  def start
    tasks = []
    iter = tasks.each
    loop do
      nt = []

      shouldpop = lambda do
        return true unless @queue.empty?
        return true if tasks.empty? && nt.empty?
        false
      end

      shouldblock = lambda do
        return true if @queue.empty? && (!tasks.empty? || !nt.empty?)
        false
      end

      while shouldpop.()
        begin
          i = @queue.pop shouldblock.()
          nt << i
        rescue ThreadError
          break
        end
      end
      nt.each do |i|
        begin
          t = i[:task]
          t.start(*i[:args], **i[:kwargs])
          tasks << t
        rescue => e
          puts e.backtrace
          puts e
        end
      end
      begin
        t = iter.next
        t.resume
        if t.done?
          @tasks -= 1
          tasks.delete t
        end
      rescue StopIteration
        iter.rewind
      end
    end
  end
end