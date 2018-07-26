# ParticlePool

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'particle_pool'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install particle_pool

## Usage

```ruby
# Require the library
require 'particle_pool'

# Create a new pool
p = ParticlePool::Pool.new

# Start it
p.start

(1024 * Etc.nprocessors).times do |i|
  # Create some tasks
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

  # And push them into the pool.
  p.push(t, i)
end

# You can wait for tasks to finish!
t = ParticlePool::Task.new do
  sleep 16
  'Hello, World!'
end
p.push(t)

puts t.await_sync

# Wait for all results to appear
while $sz != (1024 * Etc.nprocessors) do
  sleep 1
end

# Sum results and print the final result
puts $arr.reduce(:+)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/handicraftsman/particle_pool.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
