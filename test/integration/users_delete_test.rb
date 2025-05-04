require "test_helper"

class UsersDeleteTest < ActionDispatch::IntegrationTest

  def setup
    @admin        = users(:michael)
    @non_admin = users(:archer)
  end

  test "delete user" do
    log_in_as @admin
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
    assert_redirected_to users_url
    assert_response :see_other
  end

  test "error when tried to delete user while not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@non_admin)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "error when not admin user tried to delete user" do
    log_in_as(@non_admin)
    assert_no_difference 'User.count' do
      delete user_path(@admin)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end

end
