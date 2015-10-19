require_relative "../../test_helper"

class Arca::CallbackAnalysisTest < Minitest::Test
  def model
    @model ||= Arca::Model.new(Ticket)
  end

  def announce_save
    @announce_save ||= Arca::CallbackAnalysis.new(model, {
      :callback_symbol => :after_save,
      :callback_file_path => "#{Arca.root_path}/test/fixtures/announcements.rb",
      :callback_line_number => 4,
      :target_symbol => :announce_save,
      :conditional_symbol => nil,
      :conditional_target_symbol => nil
    })
  end

  def set_title
    @set_title ||= Arca::CallbackAnalysis.new(model, {
      :callback_symbol=>:before_save,
      :callback_file_path => "#{Arca.root_path}/test/fixtures/ticket.rb",
      :callback_line_number => 5,
      :target_symbol => :set_title,
      :conditional_symbol => nil,
      :conditional_target_symbol => nil
    })
  end

  def upcase_title
    @upcase_title ||= Arca::CallbackAnalysis.new(model, {
      :callback_symbol => :before_save,
      :callback_file_path => "#{Arca.root_path}/test/fixtures/ticket.rb",
      :callback_line_number => 6,
      :target_symbol => :upcase_title,
      :conditional_symbol => :if,
      :conditional_target_symbol => :title_is_a_shout?
    })
  end

  def test_callback_symbol
    assert_equal :after_save, announce_save.callback_symbol
    assert_equal :before_save, set_title.callback_symbol
    assert_equal :before_save, upcase_title.callback_symbol
  end

  def test_callback_file_path
    assert_match "test/fixtures/announcements.rb", announce_save.callback_file_path
    assert_match "test/fixtures/ticket.rb", set_title.callback_file_path
    assert_match "test/fixtures/ticket.rb", upcase_title.callback_file_path
  end

  def test_callback_line_number
    assert_equal 4, announce_save.callback_line_number
    assert_equal 5, set_title.callback_line_number
    assert_equal 6, upcase_title.callback_line_number
  end

  def test_external_callback?
    assert_predicate announce_save, :external_callback?
    refute_predicate set_title, :external_callback?
    refute_predicate upcase_title, :external_callback?
  end

  def test_target_symbol
    assert_equal :announce_save, announce_save.target_symbol
    assert_equal :set_title, set_title.target_symbol
    assert_equal :upcase_title, upcase_title.target_symbol
  end

  def test_target_file_path
    assert_match "test/fixtures/announcements.rb", announce_save.target_file_path
    assert_match "test/fixtures/ticket.rb", set_title.target_file_path
    assert_match "test/fixtures/ticket.rb", upcase_title.target_file_path
  end

  def test_target_line_number
    assert_equal 20, announce_save.target_line_number
    assert_equal 8, set_title.target_line_number
    assert_equal 16, upcase_title.target_line_number
  end

  def test_external_target?
    refute_predicate announce_save, :external_target?
    refute_predicate set_title, :external_target?
    refute_predicate upcase_title, :external_target?
  end

  def test_lines_to_target
    assert_equal 16, announce_save.lines_to_target
    assert_equal 3, set_title.lines_to_target
    assert_equal 10, upcase_title.lines_to_target
  end

  def test_conditional_symbol
    assert_nil announce_save.conditional_symbol
    assert_nil set_title.conditional_symbol
    assert_equal :if, upcase_title.conditional_symbol
  end

  def test_conditional_target_symbol
    assert_nil announce_save.conditional_target_symbol
    assert_nil set_title.conditional_target_symbol
    assert_equal :title_is_a_shout?, upcase_title.conditional_target_symbol
  end

  def test_conditional_target_file_path
    assert_nil announce_save.conditional_target_file_path
    assert_nil set_title.conditional_target_file_path
    assert_match "test/fixtures/ticket.rb", upcase_title.conditional_target_file_path
  end

  def test_conditional_target_line_number
    assert_nil announce_save.conditional_target_line_number
    assert_nil set_title.conditional_target_line_number
    assert_equal 20, upcase_title.conditional_target_line_number
  end

  def test_lines_to_conditional_target
    assert_nil announce_save.lines_to_conditional_target
    assert_nil set_title.lines_to_conditional_target
    assert_equal 14, upcase_title.lines_to_conditional_target
  end
end
