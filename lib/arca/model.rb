module Arca
  class Model

    # Arca::Model wraps an ActiveRecord model class and provides an interface
    # to the collected and analyzed callback data for that class and the file
    # path to the model class.
    def initialize(klass)
      @klass = klass
      @name = klass.name
      @callbacks = klass.arca_callback_data.dup
      @file_path = callbacks.delete(:model_file_path)
    end

    # Array of ActiveRecord callback method symbols in a rough order of when
    # they are used in the life cycle of an ActiveRecord model.
    CALLBACKS = [
      :after_initialize, :after_find, :after_touch, :before_validation, :after_validation,
      :before_save, :around_save, :after_save, :after_save_commit,
      :before_create, :around_create, :after_create, :after_create_commit,
      :before_update, :around_update, :after_update, :after_update_commit,
      :before_destroy, :around_destroy, :after_destroy, :after_destroy_commit,
      :after_commit, :after_rollback
    ]

    # Public: ActiveRecord model class.
    attr_reader :klass

    # Public: String model name.
    attr_reader :name

    # Public: String file path.
    attr_reader :file_path

    # Public: Hash of collected callback data.
    attr_reader :callbacks

    # Public: Arca::Report for this model.
    def report
      @report ||= Report.new(self)
    end

    # Public: Helper method for finding the file path and line number where
    # a method is located for the ActiveRecord model.
    #
    # method_symbol - Symbol representation of the method name.
    def source_location(method_symbol)
      source_location = klass.instance_method(method_symbol).source_location
      {
        :file_path => source_location[0],
        :line_number => source_location[1]
      }
    rescue NameError
      {
        :file_path => nil,
        :line_number => nil
      }
    rescue TypeError
      {
        :file_path => nil,
        :line_number => nil
      }
    end

    # Public: Hash of CallbackAnalysis objects for each callback type.
    def analyzed_callbacks
      @analyzed_callbacks ||= CALLBACKS.inject({}) do |result, callback_symbol|
        Array(callbacks[callback_symbol]).each do |callback_data|
          result[callback_symbol] ||= []
          callback_analysis = CallbackAnalysis.new(self, callback_data)

          unless callback_analysis.target_file_path_active_record?
            result[callback_symbol] << callback_analysis
          end
        end
        result
      end
    end

    # Public: Array of all CallbackAnalysis objects for this model.
    def analyzed_callbacks_array
      @analyzed_callbacks_array ||= analyzed_callbacks.values.flatten
    end

    # Public: Integer representing the number of callbacks analyzed.
    def analyzed_callbacks_count
      analyzed_callbacks_array.size
    end

    # Public: Integer representing the total number of lines between callbacks
    # called for this class from files other than the one where the class is
    # defined.
    def lines_between_count
      lines_between = 0
      line_numbers = analyzed_callbacks_array.map &:callback_line_number
      sorted_line_numbers = line_numbers.sort {|a,b| b <=> a }
      sorted_line_numbers.each_with_index do |line_number, index|
        lines_between += line_number - (sorted_line_numbers[index + 1] || 0)
      end
      lines_between
    end

    # Public: Integer representing the number of callbacks called for this class
    # from files other than this model.
    def external_callbacks_count
      analyzed_callbacks_array.select {|analysis| analysis.external_callback? }.size
    end

    # Public: Integer representing the number of callback targets that are
    # defined in files other than this model.
    def external_targets_count
      analyzed_callbacks_array.select {|analysis| analysis.external_target? }.size
    end

    # Public: Integer representing the number of conditional callback targets
    # that are defined in files other than this model.
    def external_conditionals_count
      analyzed_callbacks_array.select {|analysis| analysis.external_conditional_target? }.size
    end
  end
end
