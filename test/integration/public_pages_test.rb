require "test_helper"

class PublicPagesTest < ActionDispatch::IntegrationTest
  test "home renders" do
    get root_path
    assert_response :success
    assert_select "h1"
  end

  test "pricing renders" do
    get pricing_path
    assert_response :success
  end

  test "sign-in renders the email step" do
    get new_session_path
    assert_response :success
  end

  test "signup renders when signups are open" do
    Account.destroy_all # single-tenant opens signups only when no account exists yet
    get new_registration_path
    assert_response :success
  end

  test "signup is closed once an account exists (single-tenant)" do
    assert Account.any?
    get new_registration_path
    assert_redirected_to new_session_path
  end
end
