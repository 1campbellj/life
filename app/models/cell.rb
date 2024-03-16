# frozen_string_literal: true

class Cell
  attr_accessor :x, :y, :state, :width, :shape

  def initialize(x:, y:, width:)
    @x = x
    @y = y
    @state = :dead
    @width = width
    @shape = false
  end

  def life
    @state = :alive
  end

  def kill
    @state = :dead
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

  def primitive
    { x: width * @x, y: @width * @y, w: @width, h: @width, primitive_marker: (alive? || shape?) ? :solid : :border }
  end
end
