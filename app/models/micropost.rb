class Micropost < ApplicationRecord
  belongs_to :user
  
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 255 }
  
  
  def like(micropost)
      user.favorites.find_or_create_by(like_id: micropost.id)
  end
  
  def unlike(micropost)
    favorite = self.favorites.find_by(like_id: micropost.id)
    favorite.destroy if favorite
  end
  
  def like?(micropost)
    self.likes.include?(micropost)
  end
end
