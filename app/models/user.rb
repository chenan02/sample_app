class User < ActiveRecord::Base
    attr_accessor :remember_token
    before_save { self.email = email.downcase }
    validates :name, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
    has_secure_password #hash password & compare to hash in db, dont save actual. needs password_digest in table
    validates :password, presence: true, length: { minimum: 6 }
    
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
    
    # returns true if given token matches digest
    def authenticated?(remember_tokem)
        return false if remember_digest.nil?
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end
    
    # forgets user
    def forget
        update_attribute(:remember_digest, nil)
    end
end
