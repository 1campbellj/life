require_relative "hood"
require_relative "set"

class Dish
  WIDTH = 1120
  HEIGHT = 720
  attr_accessor :cells, :kill_n, :life_n, :args

  def initialize(args:, width:, kill_n: [0, 1, 4, 5, 6, 7, 8], life_n: [3] )
    cols = (WIDTH / width).round
    rows = (HEIGHT / width).round
    @cells = Array.new(rows).fill { |r| Array.new(cols).fill {|c| Cell.new(args: args, x: c, y: r, w: width ) }}
    @kill_n = kill_n
    @life_n = life_n
    @args = args
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

  def relevant_cells
    args.state.changed_cells.map { |x, y|
      near(y, x) << cells[y][x]
    }
  end

  def step
    return unless args.state.changed_cells.length > 0
    dup = cells.map { |g| g.map(&:dup) }

    relevant = relevant_cells.flatten!
    args.state.changed_cells = Set.new

    relevant.each do |c|
      n = near(c.dish_y, c.dish_x)
      count = n.filter(&:alive?).count

      if kill_n.include?(count)
        if c.alive?
          dup[c.dish_y][c.dish_x].kill
        end
      elsif life_n.include?(count)
        if !c.alive?
          dup[c.dish_y][c.dish_x].life
        end
      end
    end

    self.cells = dup
  end
end
