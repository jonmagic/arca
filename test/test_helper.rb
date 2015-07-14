$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "active_record"
require "minitest/autorun"

require "arca"
Arca.root_path = `pwd`.chomp
Arca.model_root_path = Arca.root_path + "/test/fixtures"

require_relative "fixtures/announcements"
require_relative "fixtures/ticket"

if ENV["CONSOLE"]
  require "pry"
  binding.pry
end
