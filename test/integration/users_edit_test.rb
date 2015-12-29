require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
  end
  
  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: {name:                  "",
                                   email:                 "foo@invalid",
                                   password:              "foo",
                                   password_confirmation: "bar" }
                                   
    assert_template 'users/edit'
  end
  
  test "successful edit with friendly forwarding and subsequent login attempt after logout" do
    get edit_user_path(@user)
    assert_not session[:forwarding_url].nil?
    log_in_as(@user)
    assert is_logged_in?
    assert_redirected_to edit_user_path(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), user: { name: name,
                                    email: email,
                                    password:                      "",
                                    password_confirmation:         "" }
    
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
    delete logout_path
    assert_not is_logged_in?
    assert session[:forwarding_url].nil?
    log_in_as(@user)
    assert_redirected_to user_path(@user)
    
  end
end
