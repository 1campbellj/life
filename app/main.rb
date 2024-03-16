# frozen_string_literal: true

require_relative 'models/cell'
require_relative 'models/dish'
require_relative 'models/button'

def clear_callback(args)
  args.state.dish.clear
  args.state.play = false
  args.state.buttons[2] = play_button(args)
end

def play_button(args)
    i = 2
    Button.new(text: 'Play', i: i, callback: -> { 
      args.state.play = !args.state.play 
      args.state.buttons[i] = pause_button(args)
      args.state.saved_cells = args.state.dish.cells.map { |g| g.map(&:dup) }
    })
end

def pause_button(args)
    i = 2
    Button.new(text: 'Pause', i: i, callback: -> { 
      args.state.play = !args.state.play 
      args.state.buttons[i] = play_button(args)
    })
end

def reset_button(args)
  Button.new(text: 'Reset', i: 3, callback: -> {
    args.state.dish.cells = args.state.saved_cells
  })
end

def tick(args)
  args.state.dish ||= Dish.new(width: 15)
  args.state.play ||= false
  args.state.speed ||= 8
  args.state.mouse_down ||= false
  args.state.buttons ||= [
    Button.new(text: 'Clear', i: 0, callback: -> {clear_callback(args)}),
    Button.new(text: 'Step', i: 1, callback: -> { args.state.dish.step }),
    play_button(args),
    reset_button(args),
    Button.new(text: '>>', i: 4, callback: -> { args.state.speed -= 1 }),
    Button.new(text: '<<', i: 5, callback: -> { args.state.speed += 1 })
  ]

  if args.state.play && args.state.tick_count % args.state.speed == 0
    args.state.dish.step
  end

  # handle mouse down on buttons
  if args.inputs.mouse.down
    args.state.mouse_down = true
    args.state.buttons.each do |b|
      b.down if args.inputs.mouse.down.inside_rect? b.primitive.first
    end
  end

  # handle drawing on grid with mouse down
  if args.state.mouse_down
    args.state.dish.cells.each do |r|
      r.each do |c|
        c.life if args.inputs.mouse.inside_rect? c.primitive
      end
    end
  end

  # handle mouse up
  if args.inputs.mouse.up
    args.state.mouse_down = false
    # on cells
    args.state.dish.cells.each do |r|
      r.each do |c|
        c.toggle if args.inputs.mouse.up.inside_rect? c.primitive
      end
    end

    # on buttons
    args.state.buttons.each do |b|
      if args.inputs.mouse.up.inside_rect? b.primitive.first
        b.callback&.call
        b.up
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
