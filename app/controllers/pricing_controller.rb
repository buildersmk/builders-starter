# Public pricing page. The upgrade button posts to the subscription resource, which sends a signed-in
# user to Stripe Checkout (and a guest to sign in first).
class PricingController < ApplicationController
  allow_unauthenticated_access
  layout "marketing"

  def show
  end
end
