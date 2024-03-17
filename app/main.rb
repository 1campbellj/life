# frozen_string_literal: true

require_relative 'models/cell'
require_relative 'models/dish'
require_relative 'models/button'
require_relative 'models/bool_button'

def clear_callback(args)
  args.state.dish.clear
  args.state.play = false
  args.state.buttons[2] = play_button(args)
end

def play_button(args)
    i = 2
    text = args.state.play ? 'Pause' : 'Play'
    Button.new(args: args, text: text, i: i, callback: -> { 
      # TODO fix this callback
      # only save the state if transitioning from pause to play
      args.state.play = !args.state.play 
      args.state.saved_cells = args.state.dish.cells.map { |g| g.map(&:dup) } if !args.state.saved_cells
    })
end

def reset_button(args)
  Button.new(args: args, text: 'Reset', i: 3, callback: -> {
    if args.state.saved_cells
      args.state.dish.cells = args.state.saved_cells
      args.state.saved_cells = false
    end
  })
end

SHAPE_MAP = {
  heart: [
    [0, 1, 1, 0, 1, 1, 0],
    [1, 0, 0, 1, 0, 0, 1],
    [1, 0, 0, 0, 0, 0, 1],
    [0, 1, 0, 0, 0, 1, 0],
    [0, 0, 1, 0, 1, 0, 0],
    [0, 0, 0, 1, 0, 0, 0]
  ].reverse,
  glider: [
    [0, 0, 1],
    [1, 0, 1],
    [0, 1, 1],
  ]
}

def apply_shape(args:, i:, j:)
  shape = args.state.shape
  dish = args.state.dish

  arr = SHAPE_MAP[shape]

  args.state.rotate.times do
    arr = arr.transpose.map(&:reverse)
  end

  arr.each_with_index do |r, ii|
    r.each_with_index do |c, jj|
      if c == 1
        dish[i+ii][j+jj].life
        dish[i+ii][j+jj].shape = false
      end
    end
  end
end

def handle_mouse_down(args)
  return unless args.inputs.mouse.down

  # handle buttons
  args.state.mouse_down = true
  return if args.state.shape

  # handle drawing on grid with mouse down
  args.state.dish.cells.each do |r|
    r.each do |c|
      c.life if args.inputs.mouse.inside_rect? c.primitive
    end
  end
end

def handle_mouse_draw(args)
  return if args.state.shape
  return unless args.state.mouse_down

  args.state.dish.cells.each do |r|
    r.each do |c|
      c.life if args.inputs.mouse.inside_rect? c.primitive
    end
  end
end

def handle_draw_shape(args)
  return unless args.state.shape

  mouse_i = nil
  mouse_j = nil

  args.state.dish.cells.each_with_index do |r, i|
    r.each_with_index do |c, j|
      c.shape = false
      if args.inputs.mouse.inside_rect? c.primitive
        mouse_i = i 
        mouse_j = j
      end
    end
  end

  return unless mouse_i && mouse_j
  arr = SHAPE_MAP[args.state.shape]

  args.state.rotate.times do
    arr = arr.transpose.map(&:reverse)
  end

  dish = args.state.dish
  arr.each_with_index do |r, ii|
    r.each_with_index do |c, jj|
      if c == 1 && dish[mouse_i+ii] && dish[mouse_i+ii][mouse_j+jj]
        dish[mouse_i+ii][mouse_j+jj].shape = true
      end
    end
  end
end

def handle_key_down(args)
  return unless args.inputs.keyboard.key_down

  if args.inputs.keyboard.key_down.r
    args.state.rotate += 1;
    args.state.rotate = 0 if args.state.rotate > 3
  end
end

def tick(args)
  args.state.dish ||= Dish.new(width: 12)
  args.state.play ||= false
  args.state.speed ||= 8
  args.state.mouse_down ||= false
  args.state.shape ||= nil
  args.state.rotate ||= 0
  args.state.test ||= false
  args.state.saved_cells ||= false

  args.state.buttons = [
    Button.new(args: args, text: 'Clear', i: 0, callback: -> {clear_callback(args)}),
    Button.new(args: args, text: 'Step', i: 1, callback: -> { args.state.dish.step }),
    play_button(args),
    reset_button(args),
    Button.new(args: args, text: '>>', i: 4, callback: -> { args.state.speed -= 1 }),
    Button.new(args: args, text: '<<', i: 5, callback: -> { args.state.speed += 1 }),
    Button.new(args: args, text: '<3', i: 6, callback: -> { 
      args.state.shape = :heart 
    }),
    Button.new(args: args, text: 'Glider', i: 7, callback: -> { 
      args.state.shape = :glider 
    }),
    BoolButton.new(key: :test, args: args, text: "Test", i: 8)
  ]

  if args.state.play && args.state.tick_count % args.state.speed == 0
    args.state.dish.step
  end

  handle_key_down(args)
  handle_mouse_down(args)
  handle_mouse_draw(args)
  handle_draw_shape(args)

  # handle mouse up
  if args.inputs.mouse.up
    # on cells
    args.state.dish.cells.each_with_index do |r, i|
      r.each_with_index do |c, j|
        if args.inputs.mouse.up.inside_rect? c.primitive
          if args.state.shape
            apply_shape(args: args, i: i, j: j)
            args.state.shape = nil
          else
            c.toggle if !args.state.mouse_down
          end
        end
      end
    end

    args.state.mouse_down = false

    # on buttons
    args.state.buttons.each do |b|
      if args.inputs.mouse.up.inside_rect? b.primitive.first
        b.callback&.call
      end
    end
  end

  args.state.dish.cells.each do |r|
    args.outputs.primitives << r.each.map(&:primitive)
  end

  args.state.buttons.each do |bs|
    args.outputs.primitives << bs.primitive
  end

  args.outputs.labels << [1135, 25, "f-rate: #{args.gtk.current_framerate.round}"]
end

$gtk.reset
