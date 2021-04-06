module Vic20
  class VIC
    PHI2 = 14_318_181.0 / 14

    COLOURS = [
      { name: 'BLACK',        rgb: [0.0, 0.0, 0.0] },
      { name: 'WHITE',        rgb: [0.99609375, 0.99609375, 0.99609375] },
      { name: 'RED',          rgb: [0.9609375, 0.09765625, 0.23828125] },
      { name: 'CYAN',         rgb: [0.26953125, 0.97265625, 0.95703125] },
      { name: 'PURPLE',       rgb: [0.984375, 0.265625, 0.765625] },
      { name: 'GREEN',        rgb: [0.28125, 0.921875, 0.66796875] },
      { name: 'BLUE',         rgb: [0.09765625, 0.36328125, 0.94921875] },
      { name: 'YELLOW',       rgb: [0.98828125, 0.90625, 0.42578125] },
      { name: 'ORANGE',       rgb: [0.96875, 0.38671875, 0.29296875] },
      { name: 'LIGHT_ORANGE', rgb: [0.9765625, 0.75, 0.8671875] },
      { name: 'PINK',         rgb: [0.9453125, 0.6796875, 0.890625] },
      { name: 'LIGHT_CYAN',   rgb: [0.6640625, 0.9140625, 0.86328125] },
      { name: 'LIGHT_PURPLE', rgb: [0.89453125, 0.7265625, 0.95703125] },
      { name: 'LIGHT_GREEN',  rgb: [0.671875, 0.859375, 0.6484375] },
      { name: 'LIGHT_BLUE',   rgb: [0.42578125, 0.703125, 0.89453125] },
      { name: 'LIGHT_YELLOW', rgb: [0.9609375, 0.84765625, 0.65625] },
    ].freeze

    def initialize(memory)
      @memory = memory

      @cr = memory.map_io_block

      # TODO: registers hold these mappings... are mapping methods no longer needed?
      # @characters = memory.map_character_rom
      # @screen = memory.map_screen_memory
    end

    attr_reader :cr

    PIXEL_WIDTH = 3
    PIXEL_HEIGHT = 2
    CHARACTER_WIDTH = 8 * PIXEL_WIDTH
    # CHARACTER_HEIGHT = 8 * PIXEL_HEIGHT

    # SCREEN_WIDTH = CHARS * PIXELS
    # SCREEN_HEIGHT = LINES * PIXELS

    def paint_frame(screen)
      # trace_registers('paint_frame')

      foreground_value = reverse_mode? ? 0 : 1

      background_rgb = COLOURS[background_colour][:rgb]
      border_rgb = COLOURS[border_colour][:rgb]
      auxiliary_rgb = COLOURS[auxiliary_colour][:rgb]

      screen_base    = screen_location
      character_base = character_location
      colour_base    = colour_location

      screen.fill 0, 0, color: border_rgb

      offset = 0

      x_origin = screen_origin_x * 4 * PIXEL_WIDTH
      y_origin = screen_origin_y * 2 * PIXEL_HEIGHT

      row_count = rows
      column_count = columns
      character_size = character_size_doubled? ? 16 : 8
      character_height = character_size * PIXEL_HEIGHT

      row_count.times do |row|
        y_base = y_origin + row * character_height

        column_count.times do |column|
          character_address = character_base + @memory.get_byte(screen_base + offset) * character_size

          character_colour = @memory.get_byte(colour_base + offset)
          character_rgb = COLOURS[character_colour & 0x07][:rgb]

          x_base = x_origin + column * CHARACTER_WIDTH

          if character_colour[3] == 0
            # hi resolution mode
            character_size.times do |y|
              character_matrix = @memory.get_byte(character_address + y)
              y1 = y_base + y * PIXEL_HEIGHT

              0.step(7, 1) do |x|
                x1 = x_base + x * PIXEL_WIDTH

                rgb = character_matrix[7 - x] == foreground_value ? character_rgb : background_rgb

                screen.rect x1, y1, x1 + PIXEL_WIDTH - 1, y1 + PIXEL_HEIGHT - 1, fill: true, color: rgb
              end
            end
          else
            # multicolour mode
            character_size.times do |y|
              character_matrix = @memory.get_byte(character_address + y)
              y1 = y_base + y * PIXEL_HEIGHT

              0.step(7, 2) do |x|
                x1 = x_base + x * PIXEL_WIDTH

                rgb = case character_matrix >> 6 - x & 0x03
                when 0x00
                  background_rgb
                when 0x01
                  border_rgb
                when 0x10
                  character_rgb
                when 0x11
                  auxiliary_rgb
                end

                screen.rect x1, y1, x1 + 2 * PIXEL_WIDTH - 1, y1 + PIXEL_HEIGHT - 1, fill: true, color: rgb
              end
            end
          end

          offset += 1
        end
      end
    end

    private

    def build_frame(&block)
      size = rows * columns

      if @frame.nil? || @frame.size != size
        @frame = Array.new(size, &block)
      else
        @frame.each_index do |index|
          @frame[index] = yield(index)
        end
      end
    end

    # 9000 ABBBBBBB
    # A: interlace mode (6560-101 only): 0=off, 1=on
    #    In this mode, the videochip will draw 525 interlaced lines of 65 cycles
    #    per line, instead of the 261 non-interlaced lines in the normal mode.
    #    This bit has no effect on the 6561-101.
    def interlace_mode?
      @cr[0][7] == 1
    end

    # 9000 ABBBBBBB
    # B: screen origin X (4 pixels granularity)
    #    6560-101: at 22 chars/line, the suitable range is 1 to 8
    # 	     With 22 chars/line, the value 8 will show only 5 pixels of the
    # 	     rightmost column
    #    6561-101: at 22 chars/line, the suitable range is 5 to 19
    # 	     With 22 chars/line, the value 20 will show only 5 pixels of the
    # 	     rightmost column
    #
    #    Both:     If the value B+2*D is greater than CYCLES_PER_LINE-4,
    # 	     the picture will mix up.
    #              With the value 0, there is some disturbance on the screen bottom.
    def screen_origin_x
      @cr[0] & 0x7f
    end

    # 9001 CCCCCCCC
    # C: screen origin Y (2 lines granularity)
    #    6560-101: suitable range is 5 to 130=(261-1)/2,
    # 	     which will display one raster line of text.
    #    6561-101: suitable range is 5 to 155=312/2-1
    #    Both:     No wraparound.  The bottom-most line on the screen is 0.
    def screen_origin_y
      @cr[1]
    end

    # 9002 HDDDDDDD
    # D: number of video columns
    #    6560 range: 0-26 makes sense, >31 will be interpreted as 31.
    #    6561-101: 0-29 makes sense, >32 will be interpreted as 32.
    def columns
      @cr[2] & 0x7f
    end

    # 9003 GEEEEEEF
    # E: number of video rows (0-63)
    #    6560-101 practical range: 0-29; at C=5, >=32 gives 31-3/8
    #    6561-101 practical range: 0-35; at C=5, >=38 gives 37-3/4
    def rows
      @cr[3] >> 1 & 0x3f
    end

    # 9003 GEEEEEEF
    # F: character size (1=8x16, 0=8x8)
    def character_size_doubled?
      @cr[3][0] == 1
    end

    # 9003 GEEEEEEF
    # 9004 GGGGGGGG
    # G: current raster line ($9004=raster counter b8-b1, $9003 bit 7 = b0)
    #    Vertical blank is on lines 0 through 27.
    def raster_line
      @cr[4] << 1 | @cr[3][7]
    end

    # 9002 HDDDDDDD
    # 9005 HHHHIIII
    # H: screen memory location ($9005:7-4 = b13-b10,
    #                            $9002:7 = b9 of screen and colour memory)
    #
    # Values for bit 9 set to 1
    # Value (bits 10-13)	Location hex	Location dec	Contents
    # 10[0000][1]0 0	8200	33280	character ROM
    # 10[0001][1]0 1	8600	34304	character ROM
    # 10[0010][1]0 2	8A00	35328	character ROM
    # 10[0011][1]0 3	8E00	36352	character ROM
    # 10[0100][1]0 4	9200	37376	I/O block 1 (VIC and VIAs) / alternative color RAM location
    # 10[0101][1]0 5	9600	38400	normal color RAM
    # 10[0110][1]0 6	9A00	39424	I/O block 2
    # 10[0111][1]0 7	9E00	40448	I/O block 3
    # 00[0000][1]0 8	0200	512	RAM
    # 00[0001][1]0 9	0600	1536	RAM (3K memory expansion, not accessible)
    # 00[0010][1]0 10	0A00	2560	RAM (3K memory expansion, not accessible)
    # 00[0011][1]0 11	0E00	3584	RAM (3K memory expansion, not accessible)
    # 00[0100][1]0 12	1200	4608	RAM
    # 00[0101][1]0 13	1600	5632	RAM
    # 00[0110][1]0 14	1A00	6656	RAM
    # 00[0111][1]0 15	1E00	7680	RAM (default unexpanded/3K expansion)
    #
    # Values for bit 9 set to 0
    # Value (bits 10-13)	Location hex	Location dec	Contents
    # 10[0000][0]0 0	8000	32768	character ROM
    # 10[0001][0]0 1	8400	33792	character ROM
    # 10[0010][0]0 2	8800	34816	character ROM
    # 10[0011][0]0 3	8C00	35840	character ROM
    # 10[0100][0]0 4	9000	36864	I/O block 1 (VIC and VIAs) / alternative color RAM location
    # 10[0101][0]0 5	9400	37888	normal color RAM
    # 10[0110][0]0 6	9800	38912	I/O block 2
    # 10[0111][0]0 7	9C00	39936	I/O block 3
    # 00[0000][0]0 8	0000	0	RAM
    # 00[0001][0]0 9	0400	1024	RAM (3K memory expansion, not accessible)
    # 00[0010][0]0 10	0800	2048	RAM (3K memory expansion, not accessible)
    # 00[0011][0]0 11	0C00	3072	RAM (3K memory expansion, not accessible)
    # 00[0100][0]0 12	1000	4096	RAM (default with +8K or bigger expansion)
    # 00[0101][0]0 13	1400	5120	RAM
    # 00[0110][0]0 14	1800	6144	RAM
    # 00[0111][0]0 15	1C00	7168	RAM

    def screen_location
      ((@cr[5] ^ 0x80) & 0x80) << 8 | (@cr[5] & 0x70) << 6 | (@cr[2] & 0x80) << 2
    end

    def colour_location
      0x9400 | (@cr[5] & 0x80) << 2
    end

    # 9005 HHHHIIII
    # I: character memory location (b13-b10)
    # * Note that b13 is connected to the inverse of A15 on the Vic-20.
    #
    # Value	Location hex	Location dec	Contents
    # 10[0000]00 0	8000	32768	character ROM upper case normal characters
    # 10[0001]00 1	8400	33792	character ROM upper case reversed characters
    # 10[0010]00 2	8800	34816	character ROM lower case normal characters
    # 10[0011]00 3	8C00	35840	character ROM lower case reversed characters
    # 10[0100]00 4	9000	36864	I/O block 1 - VIC and VIAs
    # 10[0101]00 5	9400	37888	color RAM with memory expansion in block 1 / normal color RAM
    # 10[0110]00 6	9800	38912	I/O block 2
    # 10[0111]00 7	9C00	39936	I/O block 3
    # 00[0000]00 8	0000	0	RAM
    # 00[0001]00 9	0400	1024	RAM (+3K memory expansion, not accessible)
    # 00[0010]00 10	0800	2048	RAM (+3K memory expansion, not accessible)
    # 00[0011]00 11	0C00	3072	RAM (+3K memory expansion, not accessible)
    # 00[0100]00 12	1000	4096	RAM
    # 00[0101]00 13	1400	5120	RAM
    # 00[0110]00 14	1800	6144	RAM
    # 00[0111]00 15	1C00	7168	half RAM, half ROM of upper case normal characters since the 14-bit address space of the VIC wraps around
    def character_location
      ((@cr[5] ^ 0x08) & 0x08) << 12 | (@cr[5] & 0x07) << 10
    end

    # 9006 JJJJJJJJ
    # J: light pen X
    def light_pen_x
      @cr[6]
    end

    # 9007 KKKKKKKK
    # K: light pen Y
    def light_pen_y
      @cr[7]
    end

    # 9008 LLLLLLLL
    # L: paddle X
    def paddle_x
      @cr[8]
    end

    # 9009 MMMMMMMM
    # M: paddle Y
    def paddle_y
      @cr[9]
    end

    # 900A NRRRRRRR
    # N: bass enable,    R: freq f=Phi2/256/(128-(($900a+1)&127))
    def bass?
      @cr[0xa][7] == 1
    end

    def bass_frequency
      PHI2 / 256 / (128 - ((@cr[0xa] + 1) & 0x7f))
    end

    # 900B OSSSSSSS
    # O: alto enable,    S: freq f=Phi2/128/(128-(($900b+1)&127))
    def alto?
      @cr[0xb][7] == 1
    end

    def alto_frequency
      PHI2 / 128 / (128 - ((@cr[0xb] + 1) & 0x7f))
    end

    # 900C PTTTTTTT
    # P: soprano enable, T: freq f=Phi2/64/(128-(($900c+1)&127))
    def soprano?
      @cr[0xc][7] == 1
    end

    def soprano_frequency
      PHI2 / 64 / (128 - ((@cr[0xc] + 1) & 0x7f))
    end

    # 900D QUUUUUUU
    # Q: noise enable,   U: freq f=Phi2/32/(128-(($900d+1)&127))
    # * PAL:  Phi2=4433618/4 Hz
    # * NTSC: Phi2=14318181/14 Hz
    def noise?
      @cr[0xd][7] == 1
    end

    def noise_frequency
      PHI2 / 32 / (128 - ((@cr[0xd] + 1) & 0x7f))
    end

    # 900E WWWWVVVV
    # W: auxiliary colour
    def auxiliary_colour
      @cr[0xe] >> 4
    end

    # 900E WWWWVVVV
    # V: volume control
    def volume
      @cr[0xe] & 0x0f
    end

    # 900F XXXXYZZZ
    # X: screen colour
    def background_colour
      @cr[0xf] >> 4
    end

    # 900F XXXXYZZZ
    # Y: reverse mode
    def reverse_mode?
      @cr[0xf][3] == 0
    end

    # 900F XXXXYZZZ
    # Z: border colour
    def border_colour
      @cr[0xf] & 0x07
    end

    def trace_registers(title)
      STDERR.puts "[#{Time.now.to_f}] #{title}…"
      STDERR.puts "\tinterlace_mode? => #{interlace_mode?.inspect}"
      STDERR.puts "\tscreen_origin_x => #{screen_origin_x.inspect}"
      STDERR.puts "\tscreen_origin_y => #{screen_origin_y.inspect}"
      STDERR.puts "\tcolumns => #{columns.inspect}"
      STDERR.puts "\trows => #{rows.inspect}"
      STDERR.puts "\tcharacter_size_doubled? => #{character_size_doubled?.inspect}"
      STDERR.puts "\traster_line => #{raster_line.inspect}"
      STDERR.puts "\tscreen_location => #{format('$%04X', screen_location)}"
      STDERR.puts "\tcolour_location => #{format('$%04X', colour_location)}"
      STDERR.puts "\tcharacter_location => #{format('$%04X', character_location)}"
      STDERR.puts "\tlight_pen_x => #{light_pen_x.inspect}"
      STDERR.puts "\tlight_pen_y => #{light_pen_y.inspect}"
      STDERR.puts "\tpaddle_x => #{paddle_x.inspect}"
      STDERR.puts "\tpaddle_y => #{paddle_y.inspect}"
      STDERR.puts "\tbass? => #{bass?.inspect}"
      STDERR.puts "\tbass_frequency => #{bass_frequency.round(1)} Hz"
      STDERR.puts "\talto? => #{alto?.inspect}"
      STDERR.puts "\talto_frequency => #{alto_frequency.round(1)} Hz"
      STDERR.puts "\tsoprano? => #{soprano?.inspect}"
      STDERR.puts "\tsoprano_frequency => #{soprano_frequency.round(1)} Hz"
      STDERR.puts "\tnoise? => #{noise?.inspect}"
      STDERR.puts "\tnoise_frequency => #{noise_frequency.round(1)} Hz"
      STDERR.puts "\tauxiliary_colour => #{COLOURS[auxiliary_colour][:name]}"
      STDERR.puts "\tvolume => #{volume.inspect}"
      STDERR.puts "\tbackground_colour => #{COLOURS[background_colour][:name]}"
      STDERR.puts "\treverse_mode? => #{reverse_mode?.inspect}"
      STDERR.puts "\tborder_colour => #{COLOURS[border_colour][:name]}"
    end
  end
end
