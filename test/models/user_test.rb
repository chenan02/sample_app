require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example user", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
  end
  
  test "should be valid" do
    assert @user.valid?
  end
  
  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end
  
  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end
  
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  
  test "email valid should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end
  
  test "password should be present" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end
  
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
  
  test "destroy microposts when user destroyed" do
    @user.save
    @user.microposts.create!(content: "blah")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
  
  test "follow and unfollow user" do
    andrew = users(:andrew)
    michael = users(:michael)
    assert_not michael.following?(andrew)
    michael.follow(andrew)
    assert michael.following?(andrew)
    assert andrew.followers.include?(michael)
    michael.unfollow(andrew)
    assert_not michael.following?(andrew)
  end
  
  test "feed has right posts" do
    andrew = users(:andrew)
    michael = users(:michael)
    user_1 = users(:user_1)
    # posts from followed user
    michael.microposts.each do |post_following|
      assert andrew.feed.include?(post_following)
    end
    # posts from self
    andrew.microposts.each do |post_self|
      assert andrew.feed.include?(post_self)
    end
    # posts unfollowed
    user_1.microposts.each do |post_unfollowed|
      assert_not andrew.feed.include?(post_unfollowed)
    end
  end
end
