# frozen_string_literal: true

require_relative 'models/cell'
require_relative 'models/dish'
require_relative 'models/button'
require_relative 'models/bool_button'
require_relative 'models/set'

def clear_callback(args)
  args.state.dish.clear
  args.state.play = false
  args.state.buttons[2] = play_button(args)
  args.state.changed_cells = Set.new
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
      c.life if args.inputs.mouse.inside_rect? c
    end
  end
end

def handle_mouse_draw(args)
  return if args.state.shape
  return unless args.state.mouse_down

  args.state.dish.cells.each do |r|
    r.each do |c|
      c.life if args.inputs.mouse.inside_rect? c
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
      if args.inputs.mouse.inside_rect? c
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

def initialize_state(args)
  args.state = args.state.merge({
    dish: Dish.new(args: args, width: 7),
    play: false,
    speed: 1,
    mouse_down: false,
    shape: nil,
    rotate: 0,
    saved_cells: nil,
    kill_n: [0, 1, 4, 5, 6, 7, 8],
    life_n: [3],
    conway: true,
    changed_cells: Set.new
  })
end

def tick(args)
  if args.state.tick_count == 0
    initialize_state(args)
  end

  args.state.buttons = [
    Button.new(args: args, text: 'Clear', i: 0, callback: -> {clear_callback(args)}),
    Button.new(args: args, text: 'Step', i: 1, callback: -> { args.state.dish.step }),
    play_button(args),
    reset_button(args),
    Button.new(args: args, text: '>>', i: 4, callback: -> { args.state.speed -= 1 if args.state.speed > 1}),
    Button.new(args: args, text: '<<', i: 5, callback: -> { args.state.speed += 1 }),
    Button.new(args: args, text: '<3', i: 6, callback: -> { 
      args.state.shape = :heart 
    }),
    Button.new(args: args, text: 'Glider', i: 7, callback: -> { 
      args.state.shape = :glider 
    }),
    Button.new(args: args, text: "Conway", i: 8, state_key: :conway, callback: -> {
      args.state.conway = !args.state.conway
      args.state.kill_n = [0, 1, 4, 5, 6, 7, 8]
      args.state.life_n = [3]
      args.state.seeds = false
    }),
    Button.new(args: args, text: "Seeds", i: 9, state_key: :seeds, callback: -> {
      args.state.seeds = !args.state.seeds
      args.state.kill_n = [0, 1, 3, 4, 5, 6, 7, 8]
      args.state.life_n = [2]
      args.state.conway = false

    })
  ]

  args.state.dish.kill_n = args.state.kill_n
  args.state.dish.life_n = args.state.life_n

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
        if args.inputs.mouse.up.inside_rect? c
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

  args.outputs.sprites << args.state.dish.cells.flatten.filter{|c| !c.path.nil?}

  args.outputs.primitives << args.state.buttons.map(&:primitive)

  #args.outputs.labels << [1135, 25, "f-rate: #{args.gtk.current_framerate.round}"]
  args.outputs.primitives << args.gtk.framerate_diagnostics_primitives
end

$gtk.reset
