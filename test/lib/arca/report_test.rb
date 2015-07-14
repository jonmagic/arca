require_relative "../../test_helper"

class Arca::ReportTest < Minitest::Test
  def report
    @report ||= Arca::Report.new(Arca::Model.new(Ticket))
  end

  def test_model_class
    assert_equal "Ticket", report.model_class
  end

  def test_model_file_path
    assert_match "test/fixtures/ticket.rb", report.model_file_path
  end

  def test_lines_between_callbacks
    assert_equal 6, report.lines_between_callbacks
  end

  def test_externals
    assert_equal 1, report.externals
  end

  def test_conditionals
    assert_equal 1, report.conditionals
  end

  def test_permutations
    assert_equal 2, report.permutations
  end
end
