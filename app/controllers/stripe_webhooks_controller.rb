# Stripe's signed webhook. Public, signature-verified, idempotent. Keeps the account's plan in sync
# with the subscription. Three events are enough for a single subscription product.
class StripeWebhooksController < ApplicationController
  allow_unauthenticated_access only: :create
  skip_before_action :verify_authenticity_token, only: :create
  skip_before_action :set_current_account, only: :create # a webhook has no tenant context

  def create
    event = Stripe::Webhook.construct_event(request.raw_post, request.env["HTTP_STRIPE_SIGNATURE"], ENV["STRIPE_WEBHOOK_SECRET"])

    case event.type
    when "checkout.session.completed"
      object  = event.data.object
      account = Account.find_by(id: object.client_reference_id) || Account.find_by(stripe_customer_id: object.customer)
      Billing.new(account).activate!(stripe_customer_id: object.customer) if account
    when "customer.subscription.updated"
      subscription = event.data.object
      account = Account.find_by(stripe_customer_id: subscription.customer)
      if account
        if %w[active trialing].include?(subscription.status)
          Billing.new(account).activate!(stripe_customer_id: subscription.customer)
        else
          Billing.new(account).deactivate!
        end
      end
    when "customer.subscription.deleted"
      account = Account.find_by(stripe_customer_id: event.data.object.customer)
      Billing.new(account).deactivate! if account
    end

    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError => e
    Rails.logger.warn "Stripe webhook rejected: #{e.class} - #{e.message}"
    head :bad_request
  end
end
