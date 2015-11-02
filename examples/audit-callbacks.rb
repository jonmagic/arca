# Prints a list of Active Record callbacks for the given models
#
# Usage:
#   bundle exec audit-callbacks.rb [--skip-line-num] [Model1 Model2...]
#
skip_line_num = false
if ARGV.first == "--skip-line-num"
  ARGV.shift
  skip_line_num = true
end

unless ARGV.size > 0
  $stderr.puts "No models specified. Try script/audit-callbacks User Issue."
  exit 1
end

# Arca must be required after ActiveRecord, but before the environment loads so
# we can install Arca::Collector.
require "active_record"
require "arca"
class ActiveRecord::Base
  include Arca::Collector
end

require "config/environment"

# Returns a formatted string of a callback analysis.
#
# Examples:
#
# An unnamed (block) before_destroy callback defined in the same file as the model
# Ability before_destroy app/models/ability.rb external:false block
#
# A after_destroy callback named `dereference_asset` defined in a file outside of the model (external:true)
# Avatar after_destroy app/models/asset_uploadable.rb external:true dereference_asset
#
# A before_save callback defined by a callback class
# IssueComment before_save app/models/referrer.rb external:true Referrer::ReferenceMentionsCallback
#
def format_callback(callback, skip_line_num:)
  path = Arca.relative_path(callback.callback_file_path)
  path << ":#{callback.callback_line_number}" unless skip_line_num

  # Arca outputs object ids which triggers a diff
  # e.g. #<Referrer::ReferenceMentionsCallback:0x007f8bca3a1b48>
  target = if match = /#<(.+):.+>/.match(callback.target_symbol.to_s)
    match[1]
  else
    callback.target_symbol
  end

  [
    callback.model.name,
    callback.callback_symbol,
    path,
    "external:#{callback.external_callback?}",
    target
  ].map(&:to_s).join(" ")
end

ARGV.each do |model_name|
  begin
    model_class = model_name.constantize
  rescue NameError # test classes
    next
  end

  next unless model_class.ancestors.include?(ActiveRecord::Base)

  Arca[model_class].analyzed_callbacks.each do |callback_symbol, callbacks|
    callbacks.each do |callback|
      puts format_callback(callback, skip_line_num: skip_line_num)
    end
  end
end
