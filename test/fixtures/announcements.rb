class SomeCallbackClass
  def after_destroy(record)
    puts "after_destroy announcement callback"
  end
end

module Announcements
  def self.included(base)
    base.class_eval do
      before_save { puts "before_save announcement callback" }
      after_save :announce_save

      around_save lambda { puts "around_save announcement callback" }
      before_destroy -> { puts "before_destroy announcement callback" }

      after_destroy SomeCallbackClass.new
    end
  end

  def announce_save
    puts "saved #{self.class.name.downcase}!"
  end
end
