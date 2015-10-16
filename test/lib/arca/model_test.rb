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
    assert_equal 4, model.analyzed_callbacks[:before_save].size
    assert_equal 1, model.analyzed_callbacks[:after_save].size
  end

  def test_analyzed_callbacks_array
    assert_equal 9, model.analyzed_callbacks_array.size
    assert model.analyzed_callbacks_array[0].is_a?(Arca::CallbackAnalysis)
  end

  def test_analyzed_callbacks_count
    assert_equal 9, model.analyzed_callbacks_count
  end

  def test_lines_between_count
    assert_equal 16, model.lines_between_count
  end

  def test_external_callbacks_count
    assert_equal 5, model.external_callbacks_count
  end

  def test_external_targets_count
    assert_equal 1, model.external_targets_count
  end

  def test_external_conditionals_count
    assert_equal 0, model.external_conditionals_count
  end
end
