namespace :stripe do
  desc "Create/ensure the Pro product + price (matched by lookup_key) in Stripe"
  task setup: :environment do
    abort "Set STRIPE_SECRET_KEY first." unless Billing.configured?

    product = Stripe::Product.list(limit: 100).data.find { |p| p.name == "Pro" } ||
              Stripe::Product.create(name: "Pro")

    price = Stripe::Price.list(lookup_keys: [ Plan::LOOKUP_KEY ], active: true, limit: 1).data.first
    price ||= Stripe::Price.create(
      product: product.id,
      currency: "usd",
      unit_amount: Plan::PRICE * 100,
      recurring: { interval: Plan::INTERVAL },
      lookup_key: Plan::LOOKUP_KEY,
      nickname: "Pro #{Plan::INTERVAL}ly"
    )

    puts "✓ Product #{product.id} · Price #{price.id} (lookup_key: #{Plan::LOOKUP_KEY})"
  end

  desc "Create the webhook endpoint for HOST and print its signing secret"
  task :webhook, [ :host ] => :environment do |_t, args|
    abort "Set STRIPE_SECRET_KEY first." unless Billing.configured?
    abort "Usage: bin/rails 'stripe:webhook[https://yourhost]'" if args[:host].blank?

    endpoint = Stripe::WebhookEndpoint.create(
      url: "#{args[:host].chomp('/')}/stripe/webhooks",
      enabled_events: %w[ checkout.session.completed customer.subscription.updated customer.subscription.deleted ]
    )

    puts "✓ Webhook #{endpoint.id}"
    puts "  Add to your secrets:  STRIPE_WEBHOOK_SECRET=#{endpoint.secret}"
  end
end
