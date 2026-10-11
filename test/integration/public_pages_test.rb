require "test_helper"

class PublicPagesTest < ActionDispatch::IntegrationTest
  test "home renders" do
    get root_path
    assert_response :success
    assert_select "h1"
  end

  test "home is the marketing page outside development" do
    get root_path
    assert_response :success
    assert_match "first customer", response.body      # the marketing hero
    assert_no_match(/Your setup/, response.body)      # not the dev-only welcome checklist
  end

  test "the Starter Guide and preview are development-only (not reachable elsewhere)" do
    get "/guide"
    assert_response :not_found
    get "/preview"
    assert_response :not_found
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
