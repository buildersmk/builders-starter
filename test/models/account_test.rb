require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "single-tenant accepts signups only until the first account exists" do
    Account.multi_tenant = false
    Account.destroy_all
    assert Account.accepting_signups?

    Account.create!(name: "Solo")
    assert_not Account.accepting_signups?
  end

  test "multi-tenant always accepts signups" do
    Account.multi_tenant = true
    assert Account.accepting_signups?
  ensure
    Account.multi_tenant = false
  end

  test "grant and revoke pro" do
    account = accounts(:acme)
    account.grant_pro!
    assert account.pro?

    account.revoke_pro!
    assert account.free?
  end

  test "create_with_owner! makes the identity the owner" do
    account = Account.create_with_owner!(name: "New Co", identity: identities(:member), owner_name: "Mo")
    owner = account.users.sole
    assert_equal "owner", owner.role
    assert_equal identities(:member), owner.identity
  end
end
