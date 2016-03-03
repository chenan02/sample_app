require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:andrew)
    @micropost = @user.microposts.build(content: "yoyo")
  end
  
  test "is valid" do
    assert @micropost.valid?
  end
  
  test "user id is present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end
  
  test "content present" do
    @micropost.content = " "
    assert_not @micropost.valid?
  end
  
  test "content less than 140 chars" do
    @micropost.content = "1" * 141
    assert_not @micropost.valid?
  end
  
  test "order most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
