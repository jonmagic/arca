$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "active_record"
require "minitest/autorun"
require "arca"

class ActiveRecord::Base
  self.raise_in_transactional_callbacks = true
  include Arca::Collector
end

require_relative "fixtures/announcements"
require_relative "fixtures/ticket"
require_relative "fixtures/foo"

if ENV["CONSOLE"]
  require "pry"
  binding.pry
end
