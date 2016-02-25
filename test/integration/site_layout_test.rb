require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin = users(:andrew)
  end
  
  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    # replace ? with help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
  end
  
  test "layout links for logged in admin" do
    log_in_as(@admin)
    get users_path
    assert_select "a[href=?]", login_path, count: 0
  end
    
  
  test "signup" do
    get signup_path
    assert_select "h1", "Sign Up"
  end
end
