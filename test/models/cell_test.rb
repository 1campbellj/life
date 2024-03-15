# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../app/models/cell'

class CellTest < Minitest::Test
  def setup
    @cell = Cell.new(x: 0, y: 0, width: 20)
  end

  def test_state
    refute_predicate @cell, :alive?

    @cell.life

    assert_predicate @cell, :alive?

    @cell.kill

    refute_predicate @cell, :alive?

    @cell.toggle

    assert_predicate @cell, :alive?
  end
end
