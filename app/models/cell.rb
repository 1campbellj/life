# frozen_string_literal: true

require_relative "hood"

class Cell
  attr_sprite
  attr_accessor :state, :shape, :args, :dish_x, :dish_y

  def initialize(x:, y:, w:, args:)
    @x = x * w
    @y = y * w
    @w = w
    @h = w
    @state = :dead
    @shape = false
    @args = args
    @dish_x = x
    @dish_y = y
  end

  def path
    (alive? || shape?) ? 'sprites/live_cell.png' : nil
  end

  def life
    @state = :alive
    @args.state.changed_cells << [dish_x, dish_y]
  end

  def kill
    @state = :dead
    @args.state.changed_cells << [dish_x, dish_y]
  end

  def alive?
    @state == :alive
  end

  def toggle
    alive? ? kill : life
  end

  def shape?
    shape
  end
end
