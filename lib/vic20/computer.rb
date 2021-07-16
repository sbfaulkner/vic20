# frozen_string_literal: true
module Vic20
  class Computer
    class Window < Gosu::Window
      def initialize(vic)
        @vic = vic
        super(DISPLAY_WIDTH, DISPLAY_HEIGHT)
        self.caption = 'VIC20'
      end

      def button_down(id)
        position = KEYS[id]
        return if position.nil?
        column, row = position
        STDERR.puts ">>>>> KEY DOWN #{id}: keyboard matrix #{column},#{row}"
      end

      def button_up(id)
        position = KEYS[id]
        return if position.nil?
        column, row = position
        STDERR.puts ">>>>> KEY UP #{id}: keyboard matrix #{column},#{row}"
      end

      # TODO: delegate
      def draw
        @vic.draw
      end

      # TODO: delegate
      def update
        @vic.update
      end
    end

    def initialize(options)
      @memory = build_memory(options)

      @vic = Vic20::VIC.new(@memory)

      @processor = Processor.new(@memory, pc: options[:reset])
    end

    def run
      pid = fork do
        @processor.run
        exit!
      end

      at_exit do
        Process.kill('HUP', pid)
        Process.wait
      end

      Window.new(@vic).show
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

        memory.load_roms(*options[:roms])
      end
    end
  end
end
