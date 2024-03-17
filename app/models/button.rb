class Button
  WIDTH = 1120
  HEIGHT = 720
  attr_accessor :args, :text, :i, :width, :height, :padding, :callback, :state
  def initialize(args:, text:, i:, callback: nil)
    @args = args
    @text = text
    @i = i 
    @width = 160
    @height = 40
    @padding = 10
    @callback = callback
  end

  def state
    box = 
      {
        x: WIDTH + padding, 
        y: HEIGHT - (height * (i + 1)) + (padding/2),
        h: height - padding,
        w: width - 2*padding,
        primitive_marker: :solid
      }

    if args.state.mouse_down && args.inputs.mouse.inside_rect?(box)
      :down
    else
      :up
    end
  end

  def primitive
    [
      {
        x: WIDTH + padding, 
        y: HEIGHT - (height * (i + 1)) + (padding/2),
        h: height - padding,
        w: width - 2*padding, 
        r: state == :up ? 128 : 40,
        g: state == :up ? 128 : 40,
        b: state == :up ? 128 : 40,
        primitive_marker: :solid
      },
      {
        x: WIDTH + padding + 5,
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
