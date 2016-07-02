module Vic20
  class Memory < SimpleDelegator
    FIRMWARE_DIR = File.expand_path('../../firmware', __dir__)

    FIRMWARE = {
      'basic'      => 0xC000, # C000-DFFF   49152-57343   8K Basic ROM
      'characters' => 0x8000, # 8000-8FFF   32768-36863   4K Character generator ROM
      'kernal'     => 0xE000, # E000-FFFF   57344-65535   8K KERNAL ROM
    }.freeze

    def initialize
      super []
      load_firmware
    end

    def load_firmware
      Dir[File.join(FIRMWARE_DIR, '*.bin')].each do |path|
        firmware = File.basename(path, '.bin')

        if address = FIRMWARE[firmware.split('.').first]
          data = File.read(path, mode: 'rb')
          self[address, data.size] = data.bytes
        else
          STDERR.puts 'WARNING: Skipping unknown firmware (#{firmware}).'
        end
      end
    end
  end
end
