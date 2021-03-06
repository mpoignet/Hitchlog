class Comment < ActiveRecord::Base
  belongs_to :trip
  belongs_to :user

  validates :body, presence: true

  attr_accessible :body

  def to_s
    self.body
  end
end
