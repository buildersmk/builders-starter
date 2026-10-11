# Sends a web push notification to a PushSubscription, signed with your VAPID keys. Idle until both
# VAPID_PUBLIC_KEY and VAPID_PRIVATE_KEY are set — until then Push.configured? is false and sends
# no-op. Generate a key pair with `bin/rails vapid:generate`. Keep the payload public-safe: it may
# show on a lock screen.
class Push
  Message = Struct.new(:title, :body, :path, :tag, keyword_init: true)

  def self.configured?
    ENV["VAPID_PUBLIC_KEY"].present? && ENV["VAPID_PRIVATE_KEY"].present?
  end

  # Push.deliver(subscription, title: "...", body: "...", path: "/dashboard")
  def self.deliver(subscription, title:, body:, path: "/", tag: nil)
    return unless configured?

    WebPush.payload_send(
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh,
      auth: subscription.auth,
      message: Message.new(title:, body:, path:, tag:).to_h.compact.to_json,
      vapid: {
        subject: ENV.fetch("VAPID_SUBJECT", "mailto:support@example.com"),
        public_key: ENV["VAPID_PUBLIC_KEY"],
        private_key: ENV["VAPID_PRIVATE_KEY"]
      }
    )
  rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
    subscription.gave_up!
  end
end
