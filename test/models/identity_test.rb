require "test_helper"

class IdentityTest < ActiveSupport::TestCase
  test "generating then verifying the correct code signs in and consumes it" do
    identity = identities(:member)
    code = identity.generate_login_code!

    assert_equal :ok, identity.verify_login_code(code)
    assert identity.reload.email_confirmed?
    assert_nil identity.login_code_digest, "the code is one-time-use"
  end

  test "a wrong code is invalid and counts an attempt" do
    identity = identities(:member)
    identity.generate_login_code!

    assert_equal :invalid, identity.verify_login_code("000000")
    assert_equal 1, identity.reload.login_code_attempts
  end

  test "locks after the maximum attempts" do
    identity = identities(:member)
    identity.generate_login_code!

    (Identity::LoginCode::MAX_ATTEMPTS - 1).times { identity.verify_login_code("000000") }
    assert_equal :locked, identity.verify_login_code("000000")
  end

  test "an old code is expired" do
    identity = identities(:member)
    identity.generate_login_code!
    identity.update!(login_code_sent_at: (Identity::LoginCode::LOGIN_CODE_TTL + 1.minute).ago)

    assert_equal :expired, identity.verify_login_code("123456")
  end

  test "email is normalized and unique" do
    Identity.create!(email_address: "  Mixed@Case.COM ")
    assert Identity.exists?(email_address: "mixed@case.com")

    assert_not Identity.new(email_address: "mixed@case.com").valid?
  end
end
