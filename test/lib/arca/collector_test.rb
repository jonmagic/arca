require_relative "../../test_helper"

class Arca::CollectorTest < Minitest::Test
  def test_collects_callback_data
    callbacks = Ticket.arca_callback_data
    assert_equal 1, callbacks[:after_save].size
    assert_equal 4, callbacks[:before_save].size
    assert_equal 1, callbacks[:after_commit].size
    assert_equal 1, callbacks[:around_save].size
    assert_equal 1, callbacks[:before_destroy].size
    assert_equal 1, callbacks[:after_destroy].size


    callback = callbacks[:after_save][0]
    assert_equal :after_save, callback[:callback_symbol]
    assert_match "test/fixtures/announcements.rb", callback[:callback_file_path]
    assert_equal 11, callback[:callback_line_number]
    assert_equal :announce_save, callback[:target_symbol]
    assert_nil callback[:conditional_symbol]
    assert_nil callback[:conditional_target_symbol]

    callback = callbacks[:before_save][0]
    assert_equal :before_save, callback[:callback_symbol]
    assert_match "test/fixtures/announcements.rb", callback[:callback_file_path]
    assert_equal 10, callback[:callback_line_number]
    assert_equal :inline, callback[:target_symbol]
    assert_nil callback[:conditional_symbol]
    assert_nil callback[:conditional_target_symbol]

    callback = callbacks[:before_save][1]
    assert_equal :before_save, callback[:callback_symbol]
    assert_match "test/fixtures/ticket.rb", callback[:callback_file_path]
    assert_equal 4, callback[:callback_line_number]
    assert_equal :set_title, callback[:target_symbol]
    assert_nil callback[:conditional_symbol]
    assert_nil callback[:conditional_target_symbol]

    callback = callbacks[:before_save][2]
    assert_equal :before_save, callback[:callback_symbol]
    assert_match "test/fixtures/ticket.rb", callback[:callback_file_path]
    assert_equal 4, callback[:callback_line_number]
    assert_equal :set_body, callback[:target_symbol]
    assert_nil callback[:conditional_symbol]
    assert_nil callback[:conditional_target_symbol]

    callback = callbacks[:before_save][3]
    assert_equal :before_save, callback[:callback_symbol]
    assert_match "test/fixtures/ticket.rb", callback[:callback_file_path]
    assert_equal 5, callback[:callback_line_number]
    assert_equal :upcase_title, callback[:target_symbol]
    assert_equal :if, callback[:conditional_symbol]
    assert_equal :title_is_a_shout?, callback[:conditional_target_symbol]

    callback = callbacks[:after_commit][0]
    assert_equal :after_commit, callback[:callback_symbol]
    assert_match "test/fixtures/ticket.rb", callback[:callback_file_path]
    assert_equal 6, callback[:callback_line_number]
    assert_equal :update_timeline, callback[:target_symbol]
    assert_equal :on, callback[:conditional_symbol]
    assert_equal [:create, :destroy], callback[:conditional_target_symbol]

    callback = callbacks[:around_save][0]
    assert_equal :around_save, callback[:callback_symbol]
    assert_match "test/fixtures/announcements.rb", callback[:callback_file_path]
    assert_equal 13, callback[:callback_line_number]
    assert_equal :inline, callback[:target_symbol]
    assert_nil callback[:conditional_symbol]
    assert_nil callback[:conditional_target_symbol]

    callback = callbacks[:before_destroy][0]
    assert_equal :before_destroy, callback[:callback_symbol]
    assert_match "test/fixtures/announcements.rb", callback[:callback_file_path]
    assert_equal 14, callback[:callback_line_number]
    assert_equal :inline, callback[:target_symbol]
    assert_nil callback[:conditional_symbol]
    assert_nil callback[:conditional_target_symbol]

    callback = callbacks[:after_destroy][0]
    assert_equal :after_destroy, callback[:callback_symbol]
    assert_match "test/fixtures/announcements.rb", callback[:callback_file_path]
    assert_equal 16, callback[:callback_line_number]
    assert_equal :SomeCallbackClass, callback[:target_symbol]
    assert_nil callback[:conditional_symbol]
    assert_nil callback[:conditional_target_symbol]
  end

  def test_callback_is_reapplied_with_original_args
    foo = Foo.new
    refute       foo.boop?
    foo.save
    assert       foo.mission_complete
    assert_nil   foo.bargo
    assert_nil   foo.bazinga

    foo.boop =   true
    assert       foo.boop?
    foo.save
    assert       foo.mission_complete
    assert_equal "hello", foo.bargo
    assert_equal "world", foo.bazinga
  end
end
