require_relative "button"

class BoolButton < Button
  attr_accessor :key

  def initialize(key:, **kwargs)
    @key = key
    super(**kwargs)
  end

  def state
    args.state[key] ? :down : :up

  end

  def callback
    -> {args.state[key] = !args.state[key]}
  end
end
