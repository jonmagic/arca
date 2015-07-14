require_relative "arca/collector"
require_relative "arca/model"
require_relative "arca/report"
require_relative "arca/callback_analysis"

module Arca
  def self.[](klass)
    Arca::Model.new(klass)
  end

  def self.root_path=(path)
    @root_path = path.to_s
  end

  def self.model_path=(path)
    @model_path = path.to_s
  end

  def self.model_path
    @model_path
  end

  def self.relative_path(path)
    return if path.nil?

    if @root_path
      path.sub(/^#{Regexp.escape(@root_path) || ""}\//, "")
    else
      path
    end
  end
end
