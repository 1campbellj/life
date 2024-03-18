# frozen_string_literal: true

class Cell
  attr_sprite
  attr_accessor :state, :shape

  def initialize(x:, y:, w:)
    @x = x * w
    @y = y * w
    @w = w
    @h = w
    @state = :dead
    @shape = false
  end

  def path
    (alive? || shape?) ? 'sprites/live_cell.png' : nil
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
end
