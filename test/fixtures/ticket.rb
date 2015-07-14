class Ticket < ActiveRecord::Base
  include Arca::Collector
  include Announcements

  before_save :set_title
  before_save :upcase_title, :if => :title_is_a_shout?

  def set_title
    self.title ||= "Ticket id #{SecureRandom.hex(2)}"
  end

  def upcase_title
    self.title = title.upcase
  end

  def title_is_a_shout?
    self.title.split(" ").size == 1
  end
end
