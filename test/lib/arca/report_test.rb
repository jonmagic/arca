require_relative "../../test_helper"

class Arca::ReportTest < Minitest::Test
  def report
    @report ||= Arca::Report.new(Arca::Model.new(Ticket))
  end

  def test_model_class
    assert_equal "Ticket", report.model_name
  end

  def test_model_file_path
    assert_match "test/fixtures/ticket.rb", report.model_file_path
  end

  def callbacks_count
    assert_equal 5, report.callbacks_count
  end

  def test_conditionals_count
    assert_equal 2, report.conditionals_count
  end

  def test_calculated_permutations
    assert_equal 6, report.calculated_permutations
  end
end
