module Arca
  class Report

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
        :model_name               => model_name,
        :model_file_path          => Arca.relative_path(model_file_path),
        :callbacks_count          => callbacks_count,
        :lines_between_count      => lines_between_count,
        :included_callbacks_count => included_callbacks_count,
        :conditionals_count       => conditionals_count,
        :calculated_permutations  => calculated_permutations
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

    # Public: Integer representing the total number of lines between callbacks
    # called for this class from files other than the one where the class is
    # defined.
    def lines_between_count
      lines_between = 0
      line_numbers = model.analyzed_callbacks_array.map &:callback_line_number
      sorted_line_numbers = line_numbers.sort {|a,b| b <=> a }
      sorted_line_numbers.each_with_index do |line_number, index|
        lines_between += line_number - (sorted_line_numbers[index + 1] || 0)
      end
      lines_between
    end

    # Public: Integer representing the number of callbacks called for this class
    # from files other than the one where the class is defined.
    def included_callbacks_count
      model.analyzed_callbacks_array.select do |analysis|
        analysis.external_callback? || analysis.external_target? || analysis.external_conditional_target?
      end.size
    end

    # Public: Integer representing the number of conditionals used in callback
    # for the model being reported.
    def conditionals_count
      number_of_unique_conditionals(model.analyzed_callbacks_array)
    end

    # Public: Integer representing the possible number of permutations stemming
    # from conditionals for an instance of the model being reported during the
    # lifecycle of the object.
    def calculated_permutations
      permutations = model.analyzed_callbacks.inject([]) do |results, (key, analyzed_callbacks)|
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
