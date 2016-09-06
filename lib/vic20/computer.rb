require 'gosu'
require 'texplay'

module Vic20
  class Computer < Gosu::Window
    DISPLAY_WIDTH = 704
    DISPLAY_HEIGHT = 576

    def initialize(options)
      super DISPLAY_WIDTH, DISPLAY_HEIGHT

      self.caption = 'VIC20'

      @screen = TexPlay.create_blank_image(self, width, height)

      @memory = build_memory(options)

      @vic = Vic20::VIC.new(@memory)

      @processor = Processor.new(@memory)
      @processor.reset(options[:reset])
    end

    def draw
      @screen.draw(0, 0, 0)
    end

    def milliseconds
      @start = Time.now.to_f * 1000 unless @start

      Time.now.to_f * 1000 - @start
    end

    def run
      pid = fork do
        @processor.run
        exit!
      end

      show

      Process.kill('HUP', pid)
      Process.wait
      STDERR.puts "COMPUTER exiting"
    end

    def update
      # STDERR.puts Time.now.to_f.to_s
      @vic.paint_frame(@screen)
    end

    private

    def build_memory(options)
      Memory.new(expansion: options[:expansion]) do |memory|
        if options[:firmware]
          memory.load(options[:firmware])
        else
          memory.load_firmware
        end
      end
    end
  end
end
