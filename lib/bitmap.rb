# frozen_string_literal: true
class Bitmap
  attr_reader :columns, :rows

  def initialize(width, height, color: [0.0, 0.0, 0.0])
    @columns = width
    @rows = height
    pixel = color.map { |c| (c * 0xff).to_i } << 0xff
    @data = pixel * (width * height)
  end

  def rect(x, y, width, height, color:)
    pixel = color.map { |c| (c * 0xff).to_i } << 0xff

    (y...y + height).each do |row|
      i = (row * @columns + x) * 4
      width.times do
        @data[i, 4] = pixel
        i += 4
      end
    end
  end

  def to_blob
    @data.pack('c*')
  end
end
