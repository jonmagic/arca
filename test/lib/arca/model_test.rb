require_relative "../../test_helper"

class Arca::ModelTest < Minitest::Test
  def model
    @model ||= Arca::Model.new(Ticket)
  end

  def test_report
    assert model.report.instance_of?(Arca::Report)
  end

  def test_source_location
    source_location = model.source_location(:set_title)
    assert_match "test/fixtures/ticket.rb", source_location[:file_path]
    assert_equal 8, source_location[:line_number]
  end

  def test_source_location_with_method_symbol_with_no_associated_method
    source_location = model.source_location(:foo_bar)
    assert_nil source_location[:file_path]
    assert_nil source_location[:line_number]
  end

  def test_source_location_with_an_invalid_object
    source_location = model.source_location(lambda {})
    assert_nil source_location[:file_path]
    assert_nil source_location[:line_number]
  end

  def test_analyzed_callbacks
    assert_equal 3, model.analyzed_callbacks[:before_save].size
    assert_equal 1, model.analyzed_callbacks[:after_save].size
  end

  def test_analyzed_callbacks_array
    assert_equal 4, model.analyzed_callbacks_array.size
  end
end
