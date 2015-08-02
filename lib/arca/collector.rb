module Arca

  # Include Arca::Collector in an ActiveRecord class in order to collect data
  # about how callbacks are being used.
  module Collector

    # Internal: Regular expression used for extracting the file path and line
    # number from a caller line.
    ARCA_LINE_PARSER_REGEXP = /\A(.+)\:(\d+)\:in\s(.+)\z/
    private_constant :ARCA_LINE_PARSER_REGEXP

    # Internal: Array of conditional symbols.
    ARCA_CONDITIONALS = [:if, :unless]
    private_constant :ARCA_CONDITIONALS

    # http://ruby-doc.org/core-2.2.1/Module.html#method-i-included
    def self.included(base)
      # Get the file path to the model class that included the collector.
      model_file_path, = caller[0].partition(":")

      base.class_eval do
        # Define :arca_callback_data for storing the data we collect.
        define_singleton_method :arca_callback_data do
          @callbacks ||= {}
        end

        # Collect the model_file_path.
        arca_callback_data[:model_file_path] = model_file_path

        # Find the callback methods defined on this class.
        callback_method_symbols = singleton_methods.grep /^(after|around|before)\_/

        callback_method_symbols.each do |callback_symbol|
          # Find the UnboundMethod for the callback.
          callback_method = singleton_class.instance_method(callback_symbol)

          # Redefine the callback method so that data can be collected each time
          # the callback is used for this class.
          define_singleton_method(callback_method.name) do |*args|
            # Duplicate args before modifying.
            args_copy = args.dup

            # Get the options hash from the end of the args Array if it exists.
            options = args_copy.pop if args[-1].is_a?(Hash)

            # Iterate through the rest of the args. Each remaining arguement is
            # a Symbol representing the callback target method.
            args_copy.each do |target_symbol|

              # Find the caller line where the callback is used.
              line = caller.find {|line| line =~ /#{Regexp.escape(Arca.model_root_path)}/ }

              # Parse the line in order to extract the file path and line number.
              callback_line_matches     = line.match(ARCA_LINE_PARSER_REGEXP)

              # Find the conditional symbol if it exists in the options hash.
              conditional_symbol = ARCA_CONDITIONALS.
                find {|conditional| options && options.has_key?(conditional) }

              # Find the conditional target symbol if there is a conditional.
              conditional_target_symbol = if conditional_symbol
                options[conditional_symbol]
              end

              # Set the collector hash for this callback_symbol to an empty
              # Array if it has not already been set.
              arca_callback_data[callback_symbol] ||= []

              # Add the collected callback data to the collector Array for
              # this callback_symbol.
              arca_callback_data[callback_symbol] << {
                :callback_symbol                => callback_symbol,
                :callback_file_path             => callback_line_matches[1],
                :callback_line_number           => callback_line_matches[2].to_i,
                :target_symbol                  => target_symbol,
                :conditional_symbol             => conditional_symbol,
                :conditional_target_symbol      => conditional_target_symbol
              }

            end

            # Bind the callback method to self and call it with args.
            callback_method.bind(base).call(*args)
          end
        end
      end
    end
  end
end
