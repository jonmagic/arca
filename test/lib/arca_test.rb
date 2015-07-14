require_relative "../test_helper"

class ArcaTest < Minitest::Test
  def test_returns_model
    assert Arca[Ticket].instance_of?(Arca::Model)
  end
end
