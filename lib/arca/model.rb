module Arca
  class Model
    def initialize(klass)
      @klass = klass
      @name = klass.name
      @callbacks = klass.arca_callback_data.dup
      @file_path = callbacks.delete(:model_file_path)
    end

    CALLBACKS = [
      :after_initialize, :after_find, :after_touch, :before_validation, :after_validation,
      :before_save, :around_save, :after_save, :before_create, :around_create,
      :after_create, :before_update, :around_update, :after_update,
      :before_destroy, :around_destroy, :after_destroy, :after_commit, :after_rollback
    ]

    attr_reader :klass
    attr_reader :name
    attr_reader :file_path
    attr_reader :callbacks

    def report
      @report ||= Report.new(self)
    end

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

    def analyzed_callbacks
      @analyzed_callbacks ||= CALLBACKS.inject({}) do |result, callback_symbol|
        Array(callbacks[callback_symbol]).each do |callback_data|
          result[callback_symbol] ||= []
          result[callback_symbol] << CallbackAnalysis.new({
            :model         => self,
            :callback_data => callback_data
          })
        end
        result
      end
    end

    def analyzed_callbacks_array
      @analyzed_callbacks_array ||= analyzed_callbacks.values.flatten
    end
  end
end
