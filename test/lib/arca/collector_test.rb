require_relative "../../test_helper"

class Arca::CollectorTest < Minitest::Test
  def test_collects_callback_data
    callbacks = Ticket.arca_callback_data

    callback = callbacks[:after_save][0]
    assert_equal :after_save, callback[:callback_symbol]
    assert_match "test/fixtures/announcements.rb", callback[:callback_file_path]
    assert_equal 4, callback[:callback_line_number]
    assert_equal :announce_save, callback[:target_symbol]
    assert_nil callback[:conditional_symbol]
    assert_nil callback[:conditional_target_symbol]

    callback = callbacks[:before_save][0]
    assert_equal :before_save, callback[:callback_symbol]
    assert_match "test/fixtures/ticket.rb", callback[:callback_file_path]
    assert_equal 5, callback[:callback_line_number]
    assert_equal :set_title, callback[:target_symbol]
    assert_nil callback[:conditional_symbol]
    assert_nil callback[:conditional_target_symbol]

    callback = callbacks[:before_save][1]
    assert_equal :before_save, callback[:callback_symbol]
    assert_match "test/fixtures/ticket.rb", callback[:callback_file_path]
    assert_equal 5, callback[:callback_line_number]
    assert_equal :set_body, callback[:target_symbol]
    assert_nil callback[:conditional_symbol]
    assert_nil callback[:conditional_target_symbol]

    callback = callbacks[:before_save][2]
    assert_equal :before_save, callback[:callback_symbol]
    assert_match "test/fixtures/ticket.rb", callback[:callback_file_path]
    assert_equal 6, callback[:callback_line_number]
    assert_equal :upcase_title, callback[:target_symbol]
    assert_equal :if, callback[:conditional_symbol]
    assert_equal :title_is_a_shout?, callback[:conditional_target_symbol]
  end
end
