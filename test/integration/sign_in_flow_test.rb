require "test_helper"

class SignInFlowTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "request a code, then sign in with it" do
    identity = identities(:owner)

    perform_enqueued_jobs do
      post session_code_path, params: { email_address: identity.email_address }
    end
    assert_redirected_to new_session_path

    email = ActionMailer::Base.deliveries.last
    assert_equal [ identity.email_address ], email.to
    code = email.subject[/\d{6}/]
    assert code, "the code is in the subject"

    post session_path, params: { code: code }
    assert_response :redirect
    assert cookies[:session_id].present?, "a session cookie is set"
  end

  test "an unknown email reveals nothing and sends no mail" do
    assert_no_enqueued_emails do
      post session_code_path, params: { email_address: "nobody@example.com" }
    end
    assert_redirected_to new_session_path
  end

  test "signing up creates an account, owner and login code" do
    Account.destroy_all

    perform_enqueued_jobs do
      post registration_path, params: { name: "New Builder", email_address: "new@example.com" }
    end

    identity = Identity.find_by(email_address: "new@example.com")
    assert identity, "identity created"
    assert_equal "owner", Account.sole.users.sole.role
    assert ActionMailer::Base.deliveries.any? { |m| m.to == [ "new@example.com" ] }
    assert_redirected_to new_session_path
  end
end
