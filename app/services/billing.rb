# The Stripe boundary. Operates on an Account (the tenant subscribes). One subscription product,
# resolved by a stable price lookup_key so you can repoint the price in Stripe without a code change.
#
# Idle-until-keyed: with no STRIPE_SECRET_KEY, checkout "self-serves" the account to pro so the join
# flow is walkable in development; the portal/webhook report unavailable. Hosted Checkout + the Stripe
# Customer Portal mean there's no card UI to build here.
class Billing
  Result = Struct.new(:status, :url, :message, keyword_init: true)

  def self.configured?
    ENV["STRIPE_SECRET_KEY"].present?
  end

  def self.start_checkout(account, success_url:, cancel_url:)
    new(account).start_checkout(success_url:, cancel_url:)
  end

  def initialize(account)
    @account = account
  end

  def start_checkout(success_url:, cancel_url:)
    return self_serve unless self.class.configured?

    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      customer: ensure_customer,
      line_items: [ { price: price_id_for(Plan::LOOKUP_KEY), quantity: 1 } ],
      client_reference_id: @account.id.to_s,
      billing_address_collection: "auto",
      allow_promotion_codes: true,
      subscription_data: { metadata: { account_id: @account.id } },
      success_url: success_url,
      cancel_url: cancel_url
    )
    Result.new(status: :redirect, url: session.url)
  end

  # The Stripe-hosted Customer Portal — card, invoices, cancel all live there.
  def portal(return_url:)
    return Result.new(status: :unavailable) unless self.class.configured? && @account.stripe_customer_id.present?

    session = Stripe::BillingPortal::Session.create(customer: @account.stripe_customer_id, return_url: return_url)
    Result.new(status: :redirect, url: session.url)
  end

  # Idempotent — called by both the webhook and the success landing. The "already pro?" guard means
  # the welcome email fires exactly once.
  def activate!(stripe_customer_id:)
    @account.update!(stripe_customer_id: stripe_customer_id) if stripe_customer_id.present? && @account.stripe_customer_id != stripe_customer_id
    return if @account.pro?

    @account.grant_pro!
    deliver_welcome
  end

  def deactivate!
    @account.revoke_pro! if @account.pro?
  end

  private
    def self_serve
      unless @account.pro?
        @account.grant_pro!
        deliver_welcome
      end
      Result.new(status: :joined, message: "You're on Pro (dev self-serve — no Stripe key set).")
    end

    def deliver_welcome
      owner = @account.users.find_by(role: "owner") || @account.users.first
      MembershipMailer.welcome(owner).deliver_later if owner&.email_address.present?
    end

    def ensure_customer
      return @account.stripe_customer_id if @account.stripe_customer_id.present?

      customer = Stripe::Customer.create(
        name: @account.name,
        email: @account.users.find_by(role: "owner")&.email_address,
        metadata: { account_id: @account.id }
      )
      @account.update!(stripe_customer_id: customer.id)
      customer.id
    end

    def price_id_for(lookup_key)
      mode = Stripe.api_key.to_s.start_with?("sk_test") ? "test" : "live"
      Rails.cache.fetch("stripe:price:#{mode}:#{lookup_key}", expires_in: 1.hour) do
        price = Stripe::Price.list(lookup_keys: [ lookup_key ], active: true, limit: 1).data.first
        price&.id or raise Stripe::InvalidRequestError.new(
          "No active Stripe price for '#{lookup_key}' (#{mode}) — run `bin/rails stripe:setup`", "price"
        )
      end
    end
end
