require_relative "hood"

class Dish
  WIDTH = 1120
  HEIGHT = 720
  attr_accessor :cells, :kill_n, :life_n

  def initialize(width:, kill_n: [0, 1, 4, 5, 6, 7, 8], life_n: [3] )
    cols = (WIDTH / width).round
    rows = (HEIGHT / width).round
    @cells = Array.new(rows).fill { |r| Array.new(cols).fill {|c| Cell.new(x: c, y: r, w: width ) }}
    @kill_n = kill_n
    @life_n = life_n
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
        c.shape = false
      end
    end
  end

  def step
    dup = cells.map { |g| g.map(&:dup) }
    cells.each_with_index do |r, i|
      r.each_with_index do |c, j|

        n = near(i, j)
        count = n.filter(&:alive?).count
        
        if kill_n.include?(count)
          dup[i][j].kill
        elsif life_n.include?(count)
          dup[i][j].life
        end
      end
    end

    self.cells = dup
  end
end
