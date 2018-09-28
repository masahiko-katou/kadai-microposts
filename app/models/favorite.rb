class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :like, class_name: 'Micropost'
  
  validates :user_id, presence: true
  validates :like_id, presence: true
end
