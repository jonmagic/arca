module Arca
  class Report
    def initialize(model)
      @model = model
    end

    attr_reader :model

    def inspect
      to_hash.to_s
    end

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

    def [](key)
      to_hash[key]
    end

    def model_class
      model.name
    end

    def model_file_path
      model.file_path
    end

    def number_of_callbacks
      model.analyzed_callbacks_array.size
    end

    def lines_between_callbacks
      lines_between = 0
      line_numbers = model.analyzed_callbacks_array.map &:callback_line_number
      sorted_line_numbers = line_numbers.sort {|a,b| b <=> a }
      sorted_line_numbers.each_with_index do |line_number, index|
        lines_between += line_number - (sorted_line_numbers[index + 1] || 0)
      end
      lines_between
    end

    def externals
      model.analyzed_callbacks_array.select do |analysis|
        analysis.external? || analysis.external_target? || analysis.external_conditional_target?
      end.size
    end

    def conditionals
      callbacks_by_unique_conditional_target = model.analyzed_callbacks_array.uniq {|analysis| analysis.conditional_target_symbol }
      callbacks_by_unique_conditional_target.select {|analysis| analysis.conditional_symbol }.size
    end

    def permutations
      2**conditionals
    end
  end
end
