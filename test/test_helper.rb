$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "arca"
require "active_record"
require "minitest/autorun"
require_relative "fixtures/announcements"
require_relative "fixtures/ticket"

Arca.root_path = `pwd`.chomp

if ENV["CONSOLE"]
  require "pry"
  binding.pry
end
