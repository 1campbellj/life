class Button
  WIDTH = 1120
  HEIGHT = 720
  attr_accessor :text, :i, :width, :height, :padding, :callback, :state
  def initialize(text:, i:, state: :up, callback: nil)
    @text = text
    @i = i 
    @width = 160
    @height = 40
    @padding = 10
    @callback = callback
    @state = state
  end

  def down
    self.state = :down
  end

  def up
    self.state = :up
  end

  def primitive
    [
      {
        x: WIDTH + (padding/2), 
        y: HEIGHT - (height * (i + 1)) + (padding/2),
        h: height - padding,
        w: width - padding, 
        r: state == :up ? 128 : 40,
        g: state == :up ? 128 : 40,
        b: state == :up ? 128 : 40,
        primitive_marker: :solid
      },
      {
        x: WIDTH + padding,
        y: HEIGHT - (height * i) - padding,
        text: text,
        r: state == :up ? 0 : 255,
        g: state == :up ? 0 : 255,
        b: state == :up ? 0 : 255,
        primitive_marker: :label
      },
    ]
  end
end
