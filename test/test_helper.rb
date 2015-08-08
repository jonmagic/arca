$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "active_record"
require "minitest/autorun"
require "arca"

class ActiveRecord::Base
  if respond_to?(:raise_in_transactional_callbacks)
    self.raise_in_transactional_callbacks = true
  end

  include Arca::Collector
end

require_relative "fixtures/announcements"
require_relative "fixtures/ticket"
require_relative "fixtures/foo"

if ENV["CONSOLE"]
  require "pry"
  binding.pry
end
