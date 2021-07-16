# frozen_string_literal: true
require 'vic20/version'
require 'vic20/memory'
require 'vic20/processor'
require 'vic20/via'
require 'vic20/vic'

require 'vic20/computer'

module Vic20
  DISPLAY_WIDTH = 648
  DISPLAY_HEIGHT = 568

  KEYS = {
    Gosu::KB_F7 => [7, 7],
    Gosu::KB_F5 => [6, 7],
    Gosu::KB_F3 => [5, 7],
    Gosu::KB_F1 => [4, 7],
    Gosu::KB_DOWN => [3, 7],
    Gosu::KB_RIGHT => [2, 7],
    Gosu::KB_RETURN => [1, 7],
    Gosu::KB_DELETE => [0, 7],

    Gosu::KB_HOME => [7, 6],
    Gosu::KB_UP => [6, 6],
    Gosu::KB_EQUALS => [5, 6],
    Gosu::KB_RIGHT_SHIFT => [4, 6],
    Gosu::KB_SLASH => [3, 6],
    Gosu::KB_SEMICOLON => [2, 6],
    # Gosu::KB_* => [1, 6],
    # Gosu::KB_£ => [0, 6],

    Gosu::KB_MINUS => [7, 5],
    # Gosu::KB_@ => [6, 5],
    # Gosu::KB_: => [5, 5],
    Gosu::KB_PERIOD => [4, 5],
    Gosu::KB_COMMA => [3, 5],
    Gosu::KB_L => [2, 5],
    Gosu::KB_P => [1, 5],
    # Gosu::KB_+ => [0, 5],

    Gosu::KB_0 => [7, 4],
    Gosu::KB_O => [6, 4],
    Gosu::KB_K => [5, 4],
    Gosu::KB_M => [4, 4],
    Gosu::KB_N => [3, 4],
    Gosu::KB_J => [2, 4],
    Gosu::KB_I => [1, 4],
    Gosu::KB_9 => [0, 4],

    Gosu::KB_8 => [7, 3],
    Gosu::KB_U => [6, 3],
    Gosu::KB_H => [5, 3],
    Gosu::KB_B => [4, 3],
    Gosu::KB_V => [3, 3],
    Gosu::KB_G => [2, 3],
    Gosu::KB_Y => [1, 3],
    Gosu::KB_7 => [0, 3],

    Gosu::KB_6 => [7, 2],
    Gosu::KB_T => [6, 2],
    Gosu::KB_F => [5, 2],
    Gosu::KB_C => [4, 2],
    Gosu::KB_X => [3, 2],
    Gosu::KB_D => [2, 2],
    Gosu::KB_R => [1, 2],
    Gosu::KB_5 => [0, 2],

    Gosu::KB_4 => [7, 1],
    Gosu::KB_E => [6, 1],
    Gosu::KB_S => [5, 1],
    Gosu::KB_Z => [4, 1],
    Gosu::KB_LEFT_SHIFT => [3, 1],
    Gosu::KB_A => [2, 1],
    Gosu::KB_W => [1, 1],
    Gosu::KB_3 => [0, 1],

    Gosu::KB_2 => [7, 0],
    Gosu::KB_Q => [6, 0],
    Gosu::KB_LEFT_META => [5, 0], # CBM
    Gosu::KB_RIGHT_META => [5, 0], # CBM
    Gosu::KB_SPACE => [4, 0],
    Gosu::KB_ESCAPE => [3, 0], # STOP
    Gosu::KB_LEFT_CONTROL => [2, 0],
    Gosu::KB_RIGHT_CONTROL => [2, 0],
    Gosu::KB_LEFT => [1, 0],
    Gosu::KB_1 => [0, 0],
  }
end
