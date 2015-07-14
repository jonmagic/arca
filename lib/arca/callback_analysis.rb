module Arca
  class CallbackAnalysis
    def initialize(model:, callback_data:)
      @model                          = model
      @callback_symbol                = callback_data[:callback_symbol]
      @callback_file_path             = callback_data[:callback_file_path]
      @callback_line_number           = callback_data[:callback_line_number]
      @target_symbol                  = callback_data[:target_symbol]
      @conditional_symbol             = callback_data[:conditional_symbol]
      @conditional_target_symbol      = callback_data[:conditional_target_symbol]
    end

    def inspect
      to_hash.to_s
    end

    def to_hash
      {
        :callback                       => callback_symbol,
        :callback_file_path             => Arca.relative_path(callback_file_path),
        :callback_line_number           => callback_line_number,
        :target                         => target_symbol,
        :target_file_path               => Arca.relative_path(target_file_path),
        :target_line_number             => target_line_number,
        :external                       => external?,
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

    attr_reader :model
    attr_reader :callback_symbol
    attr_reader :callback_file_path
    attr_reader :callback_line_number
    attr_reader :target_symbol

    def target_file_path
      model.source_location(target_symbol)[:file_path]
    end

    def target_line_number
      model.source_location(target_symbol)[:line_number]
    end

    def external?
      callback_file_path != model.file_path
    end

    def external_target?
      target_file_path != callback_file_path
    end

    def lines_to_target
      return if external_target?

      (target_line_number - callback_line_number).abs
    end

    attr_reader :conditional_symbol
    attr_reader :conditional_target_symbol

    def conditional_target_file_path
      return if conditional_target_symbol.nil?

      model.source_location(conditional_target_symbol)[:file_path]
    end

    def conditional_target_line_number
      return if conditional_target_symbol.nil?

      model.source_location(conditional_target_symbol)[:line_number]
    end

    def external_conditional_target?
      return if conditional_target_symbol.nil?

      callback_file_path != conditional_target_file_path
    end

    def lines_to_conditional_target
      return if conditional_target_symbol.nil? || external_conditional_target?

      (conditional_target_line_number - callback_line_number).abs
    end
  end
end
