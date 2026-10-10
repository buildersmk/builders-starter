# Start/confirm a subscription and open the billing portal. All of it runs against Current.account.
class SubscriptionsController < ApplicationController
  before_action :require_membership

  # POST /subscription — kick off Stripe Checkout (or self-serve in dev with no key).
  def create
    result = Billing.start_checkout(Current.account,
      success_url: "#{subscription_success_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: pricing_url)

    case result.status
    when :redirect then redirect_to result.url, allow_other_host: true
    when :joined   then redirect_to dashboard_path, notice: result.message
    else redirect_to pricing_path, alert: "Billing isn't available right now."
    end
  end

  # GET /subscription/success — Stripe redirects here; re-sync from the session (idempotent).
  def success
    if params[:session_id].present? && Billing.configured?
      session = Stripe::Checkout::Session.retrieve(params[:session_id])
      if session.customer.present? && (session.payment_status == "paid" || session.status == "complete")
        Billing.new(Current.account).activate!(stripe_customer_id: session.customer)
      end
    end
    redirect_to dashboard_path, notice: "You're on Pro — welcome aboard."
  end

  # GET /billing/portal — the Stripe-hosted customer portal.
  def portal
    result = Billing.new(Current.account).portal(return_url: dashboard_url)

    if result.status == :redirect
      redirect_to result.url, allow_other_host: true
    else
      redirect_to dashboard_path, alert: "The billing portal isn't available yet."
    end
  end

  private
    def require_membership
      redirect_to new_session_path unless Current.user
    end
end
