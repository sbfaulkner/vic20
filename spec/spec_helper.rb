$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'pry'
require 'vic20'

RSpec.configure do |config|
  config.order = :random

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
