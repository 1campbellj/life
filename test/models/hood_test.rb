# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../app/models/hood'


class HoodTest < Minitest::Test

  def test_basic_near
    arr = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ]

    h = Hood.new(arr:, i: 1, j: 1)

    assert_equal [1, 2, 3, 4, 6, 7, 8, 9], h.near.sort
  end

  def test_wrap_around
    arr = [
      [ 1,  2,  3,  4],
      [ 5,  6,  7,  8],
      [ 9, 10, 11, 12],
      [13, 14, 15, 16]
    ]

    h = Hood.new(arr:, i: 0, j: 1)

    assert_equal [1, 3, 5, 6, 7, 13, 14, 15], h.near.sort

    h = Hood.new(arr:, i: 3, j: 1)

    assert_equal [1, 2, 3, 9, 10, 11, 13, 15], h.near.sort


  end
end
