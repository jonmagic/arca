module Arca
  class CallbackAnalysis

    # Arca::CallbackAnalysis takes an Arca::Model and data for a specific
    # callback and then calculates and exposes a complete analysis for the
    # callback including target methods, file paths, line numbers, booleans
    # representing whether targets are in the same file they are called from,
    # and finally the number of lines between callers and the target methods
    # they call.
    #
    # model         - Arca::Model instance.
    # callback_data - Hash with callback data collected by Arca::Collector.
    def initialize(model, callback_data)
      @model                     = model
      @callback_symbol           = callback_data.fetch(:callback_symbol)
      @callback_file_path        = callback_data.fetch(:callback_file_path)
      @callback_line_number      = callback_data.fetch(:callback_line_number)
      @target_symbol             = callback_data.fetch(:target_symbol)
      @conditional_symbol        = callback_data[:conditional_symbol]
      @conditional_target_symbol = callback_data[:conditional_target_symbol]
    end

    # Public: Hash representation of the object for interactive consoles.
    def inspect
      to_hash.to_s
    end

    # Public: Hash of collected and analyzed callback data.
    def to_hash
      {
        :callback                       => callback_symbol,
        :callback_file_path             => Arca.relative_path(callback_file_path),
        :callback_line_number           => callback_line_number,
        :external_callback              => external_callback?,
        :target                         => target_symbol,
        :target_file_path               => Arca.relative_path(target_file_path),
        :target_line_number             => target_line_number,
        :external_target                => external_target?,
        :lines_to_target                => lines_to_target,
        :conditional                    => conditional_symbol,
        :conditional_target             => conditional_target_symbol,
        :conditional_target_file_path   => Arca.relative_path(conditional_target_file_path),
        :conditional_target_line_number => conditional_target_line_number,
        :external_conditional_target    => external_conditional_target?,
        :lines_to_conditional_target    => nil
      }
    end

    # Public: Arca::Model this callback belongs to.
    attr_reader :model

    # Public: Symbol representing the callback method name.
    attr_reader :callback_symbol

    # Public: String path to the file where the callback is used.
    attr_reader :callback_file_path

    # Public: Integer line number where the callback is called.
    attr_reader :callback_line_number

    # Public: Boolean representing whether the callback is used in the same
    # file where the ActiveRecord model is defined.
    def external_callback?
      callback_file_path != model.file_path
    end

    # Public: Symbol representing the callback target method name.
    attr_reader :target_symbol

    # Public: String path to the file where the callback target is located.
    def target_file_path
      model.source_location(target_symbol)[:file_path]
    end

    # Public: Integer line number where the callback target is located.
    def target_line_number
      model.source_location(target_symbol)[:line_number]
    end

    # Public: Boolean representing whether the callback target is located in the
    # same file where the callback is defined.
    def external_target?
      return false if target_symbol == :inline
      target_file_path != callback_file_path
    end

    # Public: Integer representing the number of lines between where the
    # callback is used and the callback target is located.
    def lines_to_target
      return if external_target?
      return if target_line_number.nil? || callback_line_number.nil?

      (target_line_number - callback_line_number).abs
    end

    # Public: Symbol representing the conditional target method name.
    attr_reader :conditional_symbol
    attr_reader :conditional_target_symbol

    # Public: String path to the file where the conditional target is located.
    def conditional_target_file_path
      return if conditional_target_symbol.nil?

      model.source_location(conditional_target_symbol)[:file_path]
    end

    # Public: Integer line number where the conditional target is located.
    def conditional_target_line_number
      return if conditional_target_symbol.nil?

      model.source_location(conditional_target_symbol)[:line_number]
    end

    # Public: Boolean representing whether the conditional target is located in
    # the same file where the callback is defined.
    def external_conditional_target?
      return false if conditional_target_symbol.nil?
      return false if conditional_target_symbol.is_a?(Array)
      return false if [:create, :update, :destroy].include?(conditional_target_symbol)

      callback_file_path != conditional_target_file_path
    end

    # Public: Integer representing the number of lines between where the
    # callback is used and the conditional target is located.
    def lines_to_conditional_target
      return if conditional_target_symbol.nil? || external_conditional_target?

      (conditional_target_line_number - callback_line_number).abs
    end

    # Public: Boolean representing whether the callback target is located in the
    # ActiveRecord gem.
    def target_file_path_active_record?
      target_file_path =~ /gems\/activerecord/
    end
  end
end
