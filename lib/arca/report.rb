require "forwardable"

module Arca
  class Report
    extend Forwardable

    # Arca::Report takes an Arca::Model and compiles the analyzed callback data
    # into a short overview report for the model.
    def initialize(model)
      @model = model
    end

    # Public: Arca::Model representing the ActiveRecord class being reported.
    attr_reader :model

    # Public: Hash representation of the object for interactive consoles.
    def inspect
      to_hash.to_s
    end

    # Public: Hash of compiled report data.
    def to_hash
      {
        :model_name                  => model_name,
        :model_file_path             => Arca.relative_path(model_file_path),
        :callbacks_count             => callbacks_count,
        :conditionals_count          => conditionals_count,
        :lines_between_count         => lines_between_count,
        :external_callbacks_count    => external_callbacks_count,
        :external_targets_count      => external_targets_count,
        :external_conditionals_count => external_conditionals_count,
        :calculated_permutations     => calculated_permutations
      }
    end

    # Public: String class name of model.
    def model_name
      model.name
    end

    # Public: String file path of model.
    def model_file_path
      model.file_path
    end

    # Public: Integer representing the number of callbacks used in this model.
    def callbacks_count
      model.analyzed_callbacks_count
    end

    # Public: Integer representing the number of conditionals used in callback
    # for the model being reported.
    def conditionals_count
      number_of_unique_conditionals(model.analyzed_callbacks_array)
    end

    def_delegators :@model, :lines_between_count, :external_callbacks_count,
      :external_targets_count, :external_conditionals_count

    # Public: Integer representing the possible number of permutations stemming
    # from conditionals for an instance of the model being reported during the
    # lifecycle of the object.
    def calculated_permutations
      model.analyzed_callbacks.inject([]) do |results, (key, analyzed_callbacks)|
        results << 2 ** number_of_unique_conditionals(analyzed_callbacks)
      end.sum - number_of_unique_conditionals(model.analyzed_callbacks_array)
    end

    # Internal: Integer representing the number of unique conditions for an
    # Array of CallbackAnalysis objects.
    #
    # analyzed_callbacks - Array of CallbackAnalysis objects.
    #
    # Returns an Integer.
    def number_of_unique_conditionals(analyzed_callbacks)
      analyzed_callbacks.
        select {|analysis| analysis.conditional_symbol }.
        uniq {|analysis| analysis.conditional_target_symbol }.
        size
    end
    private :number_of_unique_conditionals
  end
end
