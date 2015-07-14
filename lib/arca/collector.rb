module Arca
  # Include Arca::Collector in any class that has Klass.after_*, Klass.around_*,
  # and Klass.before_* callbacks in order to collect data about how those
  # callbacks are being used.
  #
  # You can access the data collected directly on the class where this module
  # was included.
  #
  #   > Ticket.arca_callback_data
  #   => {:before_save=>[
  #        {:args=>[:set_title],
  #         :line=>"/Users/jonmagic/Projects/arca/test/fixtures/ticket.rb:5:in `<class:Ticket>'",
  #        }
  #      ]}
  module Collector
    class ModelRootPathRequired < StandardError; end

    ARCA_LINE_PARSER_REGEXP = /\A(.+)\:(\d+)\:in\s(.+)\z/
    private_constant :ARCA_LINE_PARSER_REGEXP

    ARCA_CONDITIONALS = [:if, :unless]
    private_constant :ARCA_CONDITIONALS

    def self.included(base)
      raise ModelRootPathRequired if Arca.model_root_path.nil?
      
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

        # Iterate through the callback methods and redefine them to collect
        # data about how and where they are used when they are used.
        callback_method_symbols.each do |callback_symbol|
          callback_method = singleton_class.instance_method(callback_symbol)

          define_singleton_method(callback_method.name) do |*args|
            options = args.pop if args[-1].is_a?(Hash)
            args.each do |target_symbol|
              line = caller.find {|line| line =~ /#{Regexp.escape(Arca.model_root_path)}/ }
              callback_line_matches     = line.match(ARCA_LINE_PARSER_REGEXP)
              conditional_symbol        = ARCA_CONDITIONALS.find {|conditional| options && options.has_key?(conditional) }
              conditional_target_symbol = if conditional_symbol
                options[conditional_symbol]
              end

              arca_callback_data[callback_symbol] ||= []
              arca_callback_data[callback_symbol] << {
                :callback_symbol                => callback_symbol,
                :callback_file_path             => callback_line_matches[1],
                :callback_line_number           => callback_line_matches[2].to_i,
                :target_symbol                  => target_symbol,
                :conditional_symbol             => conditional_symbol,
                :conditional_target_symbol      => conditional_target_symbol
              }
              callback_method.bind(self).call(*args)
            end
          end
        end
      end
    end
  end
end
