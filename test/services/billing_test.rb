require "test_helper"

class BillingTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "without a Stripe key, checkout self-serves to pro" do
    account = accounts(:acme)
    assert_not Billing.configured?, "no STRIPE_SECRET_KEY in test"

    result = nil
    assert_enqueued_emails 1 do # the welcome email
      result = Billing.start_checkout(account, success_url: "https://x", cancel_url: "https://y")
    end

    assert_equal :joined, result.status
    assert account.reload.pro?
  end

  test "activate! grants once and emails the owner exactly once" do
    account = accounts(:acme)

    assert_enqueued_emails 1 do
      Billing.new(account).activate!(stripe_customer_id: "cus_test")
    end
    assert account.reload.pro?
    assert_equal "cus_test", account.stripe_customer_id

    assert_no_enqueued_emails do # a repeat webhook/landing doesn't re-grant or re-email
      Billing.new(account).activate!(stripe_customer_id: "cus_test")
    end
  end

  test "deactivate! drops back to free" do
    account = accounts(:acme)
    account.grant_pro!
    Billing.new(account).deactivate!
    assert account.reload.free?
  end
end
