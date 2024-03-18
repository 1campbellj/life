# frozen_string_literal: true

require_relative '../../app/models/cell'

class CellTest
  def setup args
    cell = Cell.new(x: 0, y: 0, width: 20, args: args)
  end

  def test_state args, assert
    cell = setup args

    assert cell.alive?

  end
end
