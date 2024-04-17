module Arca

  # Include Arca::Collector in an ActiveRecord class in order to collect data
  # about how callbacks are being used.
  module Collector

    # Internal: Regular expression used for extracting the file path and line
    # number from a caller line.
    ARCA_CALLBACK_FINDER_REGEXP = /\A(.+)\:(\d+)\:in\s[`'].+'\z/
    private_constant :ARCA_CALLBACK_FINDER_REGEXP

    # Internal: Array of conditional symbols.
    ARCA_CONDITIONALS = [:if, :unless, :on]
    private_constant :ARCA_CONDITIONALS

    # http://ruby-doc.org/core-2.2.1/Module.html#method-i-included
    def self.included(base)
      base.class_eval do
        define_singleton_method(:arca_callback_data) do
          @arca_callback_data ||= Hash.new {|k,v| k[v] = [] }
        end

        # Find the callback methods defined on this class.
        callback_method_symbols = singleton_methods.grep(/^(after|around|before)\_/)

        callback_method_symbols.each do |callback_symbol|
          # Find the UnboundMethod for the callback.
          callback_method = singleton_class.instance_method(callback_symbol)

          # Redefine the callback method so that data can be collected each time
          # the callback is used for this class.
          define_singleton_method(callback_method.name) do |*args, &block|
            # Duplicate args before modifying.
            args_copy = args.dup

            # Add target_symbol :inline to args_copy if given a block or Proc and
            # class name if a class or instance was given.
            if block
              args_copy.unshift(:inline)
            elsif args_copy.first.kind_of?(Proc)
              args_copy.shift
              args_copy.unshift(:inline)
            elsif !args_copy.first.kind_of?(Symbol)
              class_or_instance = args_copy.shift

              if class_or_instance.class == Class
                args_copy.unshift(class_or_instance.name.to_sym)
              else
                args_copy.unshift(class_or_instance.class.name.to_sym)
              end
            end

            # Get the options hash from the end of the args Array if it exists.
            options = args_copy.pop if args[-1].is_a?(Hash)

            # Get the callback file path and line number from the caller stack.
            callback_file_path, callback_line_number = ARCA_CALLBACK_FINDER_REGEXP.match(caller.first)[1..2]

            # Extract the model file path from the caller stack.
            caller.each do |line|
              if match = /\A(.+):\d+:in\s[`']<class:#{name.split("::").last}>'/.match(line)
                self.arca_callback_data[:model_file_path] = match[1]
                break
              end
            end

            # Iterate through the rest of the args. Each remaining arguement is
            # a Symbol representing the callback target method.
            args_copy.each do |target_symbol|
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
                :callback_file_path             => callback_file_path,
                :callback_line_number           => callback_line_number.to_i,
                :target_symbol                  => target_symbol,
                :conditional_symbol             => conditional_symbol,
                :conditional_target_symbol      => conditional_target_symbol
              }
            end

            # Bind the callback method to self and call it with args.
            callback_method.bind(self).call(*args, &block)
          end
        end
      end
    end
  end
end
