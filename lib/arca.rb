require_relative "arca/collector"
require_relative "arca/model"
require_relative "arca/report"
require_relative "arca/callback_analysis"

module Arca

  # Error raised if Arca[] is passed something other than a class constant.
  class ClassRequired < StandardError; end

  # Error raised if model does not respond to arca_callback_data
  class CallbackDataMissing < StandardError; end

  # Public: Reader method for accessing the Arca::Model for analysis and
  # reporting.
  def self.[](klass)
    raise ClassRequired unless klass.kind_of?(Class)
    raise CallbackDataMissing unless klass.respond_to?(:arca_callback_data)

    Arca::Model.new(klass)
  end

  # Public: Writer method for configuring the root path of the
  # project where  Arca is being used. Setting Arca.root_path will makes
  # inspecting analyzed callbacks easier by shortening absolute paths to
  # relative paths.
  #
  # path - Pathname or String representing the root path of the project.
  def self.root_path=(path)
    @root_path = path.to_s
  end

  # Public: String representing the root path for the project.
  def self.root_path
    @root_path ||= Dir.pwd
  end

  # Public: Helper method for turning absolute paths into relative paths.
  #
  # path - String absolute path.
  #
  # Returns a relative path String.
  def self.relative_path(path)
    return if path.nil?

    if root_path
      path.sub(/^#{Regexp.escape(root_path) || ""}\//, "")
    else
      path
    end
  end
end
