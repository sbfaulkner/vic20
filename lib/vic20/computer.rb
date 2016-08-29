require 'gosu'
require 'texplay'

module Vic20
  class Computer < Gosu::Window
    module ZOrder
      BACKGROUND, SCREEN = *(0..1)
    end

    CHARS = 22
    LINES = 23

    PIXELS = 8
    PIXEL_WIDTH = 4
    PIXEL_HEIGHT = 3

    SCREEN_WIDTH = CHARS * PIXELS
    SCREEN_HEIGHT = LINES * PIXELS

    DISPLAY_WIDTH = 720
    DISPLAY_HEIGHT = 525

    def initialize
      super DISPLAY_WIDTH, DISPLAY_HEIGHT

      self.caption = 'VIC20'

      @screen_width  = SCREEN_WIDTH
      @screen_height = SCREEN_HEIGHT

      @screen_left = (width - @screen_width) / 2
      @screen_top  = (height - @screen_height) / 2

      @background = TexPlay.create_blank_image(self, width, height)
      @screen     = TexPlay.create_blank_image(self, @screen_width, @screen_height)
    end

    def draw
      @background.draw(0, 0, ZOrder::BACKGROUND)
      @screen.draw(@screen_left, @screen_top, ZOrder::SCREEN)
    end

    require 'byebug'
    def tick
      # byebug
      super
    end

    # def milliseconds
    #   @start = Time.now.to_f * 1000 unless @start
    #
    #   Time.now.to_f * 1000 - @start
    # end
    #
    # def show
    #   time_before_tick = milliseconds
    #
    #   # tick is not considered a stable interface...
    #   # we can either talk to gosu authors about making it stable
    #   # or, we can use the gosu loop instead of our own
    #   # TODO: for now the idea is to replace this tick loop with our own
    #   #       which may not require override of show
    #   #       it may be as "simple" as changing the update_interval and overriding tick
    #   #       Monitor class might be the actual Vic20 ?
    #   #       or maybe this is the VIC and we can spawn a separate thread for the processor?
    #   while tick
    #     tick_time = milliseconds - time_before_tick
    #     sleep((update_interval - tick_time) / 1000) if tick_time < update_interval
    #     time_before_tick = milliseconds
    #   end
    # end

    def update
    end
  end
end
