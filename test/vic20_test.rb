# frozen_string_literal: true
require 'test_helper'

class Vic20Test < Minitest::Test
  def test_has_version
    refute_nil(Vic20::VERSION)
  end
end
