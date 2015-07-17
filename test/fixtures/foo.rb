class Foo
  extend ActiveModel::Callbacks
  define_model_callbacks :save

  include Arca::Collector
  before_save :bar, :baz, :if => :boop?

  def initialize
    @mission_complete = false
  end

  def save
    run_callbacks :save do
      @mission_complete = true
    end
  end
  attr_reader :mission_complete

  def bar
    @bargo = "hello"
  end
  attr_reader :bargo

  def baz
    @bazinga = "world"
  end
  attr_reader :bazinga

  def boop?
    !!@boop
  end
  attr_writer :boop
end
