require "minitest"

class ActiveRecordLintTest < Minitest::Test
  def test_callbacks_must_be_defined_in_the_base_model_file
    whitelist_path = File.expand_path("../active_record_callback_whitelist.txt", __FILE__)
    whitelisted_callbacks = if File.exists?(whitelist_path)
      File.read(whitelist_path).split("\n")
    else
      ""
    end

    # git grep... list classes with a parent. Does not handle classes nested within a module
    # xargs... arca analyze. We skip line numbers so we can diff the results
    # grep... filter for callbacks defined in external files or callbacks without names
    #
    # To update the whitelist, save the output up to script/audit-callbacks.
    callback_output = IO.popen(<<-CMD).read
      git grep -h '^class.*< ' -- '*.rb' | cut -d' ' -f 2 | sort -u | \
      xargs bundle exec audit-callbaks.rb --skip-line-num | \
      grep -E 'external:true|block$'
    CMD

    actual_callbacks = callback_output.split("\n")

    new_bad_callbacks = actual_callbacks - whitelisted_callbacks
    unnecessary_whitelist_entries = whitelisted_callbacks - actual_callbacks

    message = ""
    if new_bad_callbacks.any?
      message << "The following ActiveRecord callbacks must be defined in the base model file with a named method:\n\n"
      message << new_bad_callbacks.join("\n")
    end

    if unnecessary_whitelist_entries.any?
      message << "\n\n" unless message.empty?
      message << "Hooray! You removed a bad ActiveRecord callback. Please update #{whitelist_path} and remove the following\n\n"
      message << unnecessary_whitelist_entries.join("\n")
    end

    assert message.empty?, message
  end
end
