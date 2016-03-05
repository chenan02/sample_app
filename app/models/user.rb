class User < ActiveRecord::Base
    # dependent :destroy means if user destroyed, microposts destroyed
    has_many :microposts, dependent: :destroy
    # must clarify active_relationships modeled by class different name
    has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
    has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
    # call ut following because followeds is weird
    # active reacord creates following_ids method
    has_many :following, through: :active_relationships, source: :followed
    has_many :followers, through: :passive_relationships
    
    attr_accessor :remember_token, :activation_token, :reset_token
    # look for fxns below to call before saving
    before_save :downcase_email
    before_create :create_activation_digest
    validates :name, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
    has_secure_password #hash password & compare to hash in db, dont save actual. needs password_digest in table
    validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
    
    # returns hash digest of given string
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end
    
    # returns random token for cookies
    def User.new_token
        SecureRandom.urlsafe_base64
    end
    
    # associate token and its digest by updating remember digest
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end
    
    # metaprogramming - either matches password digest or activation with given
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end
    
    
    # forgets user
    def forget
        update_attribute(:remember_digest, nil)
    end
    
    # activates account
    def activate
        update_attribute(:activated, true)
        update_attribute(:activated_at, Time.zone.now)
    end
    
    # sends activation email
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end
    
    # sets password reset attributes
    def create_reset_digest
        self.reset_token = User.new_token
        update_attribute(:reset_digest, User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
    end
    
    #sends password reset email
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end
    
    # true if password reset expired
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end
    
    # selects all the posts owned by the user (? avoids sql injection)
    def feed
        # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id", following_ids: following_ids, user_id: id)
        # below more efficient, pushes set logic into database?
        following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
    end
    
    # follow other_user
    def follow(other_user)
        active_relationships.create(followed_id: other_user.id)
    end
    
    # unfollow other_user
    def unfollow(other_user)
        active_relationships.find_by(followed_id: other_user.id).destroy
    end
    
    # true if following other_user
    def following?(other_user)
        following.include?(other_user)
    end
    
    private
    
        def downcase_email
            self.email = email.downcase
        end
        
        def create_activation_digest
            self.activation_token = User.new_token
            self.activation_digest = User.digest(activation_token)
        end
end
