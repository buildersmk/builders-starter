require "test_helper"

class PushTest < ActiveSupport::TestCase
  test "configured? follows the VAPID environment" do
    with_vapid(nil, nil) { assert_not Push.configured? }
    with_vapid("pub", "priv") { assert Push.configured? }
  end

  test "deliver is a silent no-op when unconfigured" do
    with_vapid(nil, nil) do
      subscription = PushSubscription.new(endpoint: "https://x", p256dh: "y", auth: "z")
      assert_nil Push.deliver(subscription, title: "Hi", body: "there")
    end
  end

  private
    def with_vapid(public_key, private_key)
      old = ENV.values_at("VAPID_PUBLIC_KEY", "VAPID_PRIVATE_KEY")
      public_key ? ENV["VAPID_PUBLIC_KEY"] = public_key : ENV.delete("VAPID_PUBLIC_KEY")
      private_key ? ENV["VAPID_PRIVATE_KEY"] = private_key : ENV.delete("VAPID_PRIVATE_KEY")
      yield
    ensure
      old[0] ? ENV["VAPID_PUBLIC_KEY"] = old[0] : ENV.delete("VAPID_PUBLIC_KEY")
      old[1] ? ENV["VAPID_PRIVATE_KEY"] = old[1] : ENV.delete("VAPID_PRIVATE_KEY")
    end
end
