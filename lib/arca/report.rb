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
        :model_class         => model_class,
        :model_file_path     => Arca.relative_path(model_file_path),
        :number_of_callbacks => number_of_callbacks,
        :lines_between       => lines_between_callbacks,
        :externals           => externals,
        :conditionals        => conditionals,
        :permutations        => permutations
      }
    end

    # Public: String class name of model.
    def model_class
      model.name
    end

    # Public: String file path of model.
    def model_file_path
      model.file_path
    end

    # Public: Integer representing the number of callbacks used in this model.
    def number_of_callbacks
      model.analyzed_callbacks_array.size
    end

    # Public: Integer representing the total number of lines between callbacks
    # called for this class from files other than the one where the class is
    # defined.
    def lines_between_callbacks
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
    def externals
      model.analyzed_callbacks_array.select do |analysis|
        analysis.external_callback? || analysis.external_target? || analysis.external_conditional_target?
      end.size
    end

    # Public: Integer representing the number of conditionals used in callback
    # for the model being reported.
    def conditionals
      callbacks_by_unique_conditional_target = model.analyzed_callbacks_array.uniq {|analysis| analysis.conditional_target_symbol }
      callbacks_by_unique_conditional_target.select {|analysis| analysis.conditional_symbol }.size
    end

    # Public: Integer representing the possible number of permutations stemming
    # from conditionals for an instance of the model being reported during the
    # lifecycle of the object.
    def permutations
      2**conditionals
    end
  end
end
