class Ticket < ActiveRecord::Base
  include Announcements

  before_save :set_title, :set_body
  before_save :upcase_title, :if => :title_is_a_shout?
  after_commit :update_timeline, :on => [:create, :destroy]

  def set_title
    self.title ||= "Ticket id #{SecureRandom.hex(2)}"
  end

  def set_body
    self.body ||= "Everything is broken."
  end

  def upcase_title
    self.title = title.upcase
  end

  def title_is_a_shout?
    self.title.split(" ").size == 1
  end

  def update_timeline
    puts "Updating timeline"
  end
end
