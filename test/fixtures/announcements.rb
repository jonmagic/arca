module Announcements
  def self.included(base)
    base.class_eval do
      after_save :announce_save
    end
  end

  def announce_save
    puts "saved #{self.class.name.downcase}!"
  end
end
