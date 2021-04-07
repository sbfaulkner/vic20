# frozen_string_literal: true
require 'gosu'
require 'texplay'

module Vic20
  class Display < Gosu::Window
    DISPLAY_WIDTH = 648
    DISPLAY_HEIGHT = 568

    def initialize(vic)
      super DISPLAY_WIDTH, DISPLAY_HEIGHT

      self.caption = 'VIC20'

      @vic = vic
      @screen = TexPlay.create_blank_image(self, width, height)
    end

    def draw
      @screen.draw(0, 0, 0)
    end

    def update
      # STDERR.puts Time.now.to_f.to_s
      @vic.paint_frame(@screen)
    end
  end
end
