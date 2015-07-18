require_relative "../test_helper"

class ArcaTest < Minitest::Test
  def test_returns_model
    assert Arca[Ticket].instance_of?(Arca::Model)
  end

  def test_requires_class
    assert_raises(Arca::ClassRequired) do
      Arca[:ticket]
    end
  end

  def test_requires_callback_data
    assert_raises(Arca::CallbackDataMissing) do
      Arca[ArcaTest]
    end
  end
end
