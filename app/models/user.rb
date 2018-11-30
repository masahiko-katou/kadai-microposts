class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  before_save :downcase_email
  before_create :create_activation_digenst
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :microposts, dependent: :destroy
  has_many :relationships, dependent: :destroy
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  has_many :favorites
  
  #def favorites
    # Favorite.where(user_id: self.id)
  #end

  has_many :likes, through: :favorites, source: :like
  
  #def likes
    # Micropost.where(id: Favorite.where(user_id: self.id).pluck(:like_id))
  #end
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end
  
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end
  
  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  def like(micropost)
    self.favorites.find_or_create_by(like_id: micropost.id)
  end
  
  def unlike(micropost)
    favorite = self.favorites.find_by(like_id: micropost.id)
    favorite.destroy if favorite
  end
  
  def like?(micropost)
    self.likes.include?(micropost)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  def activate
    update_columns(activated: FILL_IN, activated_at: FILL_IN)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  private
  
    def downcase_email
      self.email = email.downcase
    end
    
    def create_activation_digenst
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
