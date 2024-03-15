require_relative "hood"

class Dish
  WIDTH = 1120
  HEIGHT = 720
  attr_accessor :cells

  def initialize(width:)
    cols = (WIDTH / width).round
    rows = (HEIGHT / width).round
    @cells = Array.new(rows).fill { |r| Array.new(cols).fill {|c| Cell.new(x: c, y: r, width: width ) }}
  end

  def [](n)
    @cells.send(:[], n)
  end

  def near(i, j)
    Hood.new(arr: cells, i: i, j: j).near
  end

  def clear
    cells.each do |r|
      r.each do |c|
        c.kill
      end
    end
  end

  def step
    dup = cells.map { |g| g.map(&:dup) }
    cells.each_with_index do |r, i|
      r.each_with_index do |c, j|

        n = near(i, j)
        count = n.filter(&:alive?).count
        
        if count < 2 || count > 3
          dup[i][j].kill
        elsif count == 3
          dup[i][j].life
        end

      end
    end

    self.cells = dup
  end
end
