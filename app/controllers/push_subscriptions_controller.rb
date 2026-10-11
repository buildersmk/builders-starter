# Saves a browser's web-push subscription (sent by push_controller.js after the person allows
# notifications). Tied to the signed-in identity so you can notify them later via Push.deliver.
class PushSubscriptionsController < ApplicationController
  # POST /push_subscription
  def create
    subscription = PushSubscription.find_or_initialize_by(endpoint: params.require(:endpoint))
    subscription.update!(
      identity: Current.identity,
      p256dh: params.dig(:keys, :p256dh),
      auth: params.dig(:keys, :auth),
      gave_up_at: nil
    )
    head :created
  end
end
