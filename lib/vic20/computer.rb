# frozen_string_literal: true
module Vic20
  class Computer
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

      Display.new(@vic).show
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

        memory.load_cartridge(options[:cartridge]) if options[:cartridge]
      end
    end
  end
end
