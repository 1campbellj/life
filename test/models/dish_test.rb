# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../app/models/dish'

class DishTest < Minitest::Test
  def setup
    @dish = Dish.new(width: 100)
  end

  def test_can_index
    refute_empty @dish[0]
    refute_nil @dish[0][0]
  end
end
