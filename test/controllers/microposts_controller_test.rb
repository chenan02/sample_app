require 'test_helper'

class MicropostsControllerTest < ActionController::TestCase
  def setup
    @micropost = microposts(:banana)
  end
  
  test "redirect create when unloggedin" do
    assert_no_difference 'Micropost.count' do
      post :create, micropost: { content: "hey" }
    end
    assert_redirected_to login_url
  end
  
  test "redirect destroy when unloggedin" do
    assert_no_difference 'Micropost.count' do
      delete :destroy, id: @micropost
    end
    assert_redirected_to login_url
  end
  
  test "redirect destroy for wrong micropost" do
    log_in_as(users(:andrew))
    micropost = microposts(:website)
    assert_no_difference 'Micropost.count' do
      delete :destroy, id: micropost
    end
    assert_redirected_to root_url
  end
end
