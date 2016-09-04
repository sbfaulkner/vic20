module Vic20
  class VIC
    BLACK        = 0
    WHITE        = 1
    RED          = 2
    CYAN         = 3
    PURPLE       = 4
    GREEN        = 5
    BLUE         = 6
    YELLOW       = 7
    ORANGE       = 8
    LIGHT_ORANGE = 9
    PINK         = 10
    LIGHT_CYAN   = 11
    LIGHT_PURPLE = 12
    LIGHT_GREEN  = 13
    LIGHT_BLUE   = 14
    LIGHT_YELLOW = 15

    def initialize(memory)
      @cr = memory.map_io_block

      @characters = memory.map_character_rom
      @screen = memory.map_screen_memory
    end

    attr_reader :cr

    CHARACTER_MEMORY_ADDRESSES = [
      0x8000,
      0x8400,
      0x8800,
      0x8c00,
      0x0000,
      0xffff,
      0xffff,
      0xffff,
      0x1000,
      0x1400,
      0x1800,
      0x1c00,
    ]

    def generate_frame
      # 1 0010110
      STDERR.puts "---- [#{Time.now.to_f}] --------------------"
      # STDERR.puts "\tCR00 ($9000) => #{@cr[0].to_s(2).rjust(8, '0')}): interlace scan => #{@cr[0][7]}, horizontal centering => #{@cr[0] & 0x7f}"
      # STDERR.puts "\tCR01 ($9001) => #{@cr[1].to_s(2).rjust(8, '0')}): vertical centering => #{@cr[1]}"
      # STDERR.puts "\tCR02 ($9002) => #{@cr[2].to_s(2).rjust(8, '0')}): video matrix address bit => #{@cr[2][7]}, # of columns => #{@cr[2] & 0x7f}"
      # STDERR.puts "\tCR03 ($9003) => #{@cr[3].to_s(2).rjust(8, '0')}): 8x8 or 16x8 characters => #{@cr[3][0]}, # of rows => #{(@cr[3] & 0x7e) >> 1}"
      # STDERR.puts "\tCR04 ($9004) => #{@cr[4].to_s(2).rjust(8, '0')}): raster beam line => #{@cr[4]}"
      # STDERR.puts "\tCR05 ($9005) => #{@cr[5].to_s(2).rjust(8, '0')}): start of character memory => #{CHARACTER_MEMORY_ADDRESSES[@cr[5] & 0x0f].to_s(16)}, rest of video address => #{@cr[2] & 0x7f}"
      # STDERR.puts "\tCR06 ($9006) => #{@cr[6].to_s(2).rjust(8, '0')}): interlace scan => #{@cr[6][7]}, horizontal centering => #{@cr[2] & 0x7f}"
      # STDERR.puts "\tCR07 ($9007) => #{@cr[7].to_s(2).rjust(8, '0')}): interlace scan => #{@cr[7][7]}, horizontal centering => #{@cr[2] & 0x7f}"
      # STDERR.puts "\tCR08 ($9008) => #{@cr[8].to_s(2).rjust(8, '0')}): interlace scan => #{@cr[8][7]}, horizontal centering => #{@cr[2] & 0x7f}"
      # STDERR.puts "\tCR09 ($9009) => #{@cr[9].to_s(2).rjust(8, '0')}): interlace scan => #{@cr[9][7]}, horizontal centering => #{@cr[2] & 0x7f}"
      # STDERR.puts "\tCR10 ($900a) => #{@cr[10].to_s(2).rjust(8, '0')}): interlace scan => #{@cr[10][7]}, horizontal centering => #{@cr[2] & 0x7f}"
      # STDERR.puts "\tCR11 ($900b) => #{@cr[11].to_s(2).rjust(8, '0')}): interlace scan => #{@cr[11][7]}, horizontal centering => #{@cr[2] & 0x7f}"
      # STDERR.puts "\tCR12 ($900c) => #{@cr[12].to_s(2).rjust(8, '0')}): interlace scan => #{@cr[12][7]}, horizontal centering => #{@cr[2] & 0x7f}"
      # STDERR.puts "\tCR13 ($900d) => #{@cr[13].to_s(2).rjust(8, '0')}): interlace scan => #{@cr[13][7]}, horizontal centering => #{@cr[2] & 0x7f}"
      # STDERR.puts "\tCR14 ($900e) => #{@cr[14].to_s(2).rjust(8, '0')}): interlace scan => #{@cr[14][7]}, horizontal centering => #{@cr[2] & 0x7f}"
      # STDERR.puts "\tCR15 ($900f) => #{@cr[15].to_s(2).rjust(8, '0')}): interlace scan => #{@cr[15][7]}, horizontal centering => #{@cr[2] & 0x7f}"
    end
  end
end
