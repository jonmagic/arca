class Foo < ActiveRecord::Base
  include Arca::Collector

  before_save :bar

  def bar
  end
end
