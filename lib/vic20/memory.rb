module Vic20
  class Memory < SimpleDelegator
    FIRMWARE_DIR = File.expand_path('../../firmware', __dir__)

    def self.find_firmware(name)
      Dir[File.join(FIRMWARE_DIR, "#{name}.*.bin")].first
    end

    DEFAULT_FIRMWARE = {
      0x8000 => find_firmware('characters'),  # 8000-8FFF   32768-36863   4K Character generator ROM
      0xc000 => find_firmware('basic'),       # C000-DFFF   49152-57343   8K Basic ROM
      0xe000 => find_firmware('kernal'),      # E000-FFFF   57344-65535   8K KERNAL ROM
    }.freeze

    def initialize(contents = nil)
      contents ||= DEFAULT_FIRMWARE
      contents = { 0 => contents } if contents.is_a?(String)

      super Array.new(64 * 1024) { |offset| offset >> 8 }

      contents.each { |address, content| load(address, content) }
    end

    def load(address, content)
      case content
      when Array
        self[address, content.size] = content
      when String
        load(address, File.read(content, mode: 'rb').bytes)
      else
        raise ArgumentError, "Unsupported content type: #{content.class.name}"
      end
    end

    def word_at(address)
      self[address] | self[address + 1] << 8
    end
  end
end
