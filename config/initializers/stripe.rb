# Stripe is idle until keyed: with no STRIPE_SECRET_KEY the billing flows self-serve (dev) and the
# webhook/ portal simply report "unavailable". Set the key in .env (or Doppler) to switch it on.
if ENV["STRIPE_SECRET_KEY"].present?
  Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
  Stripe.max_network_retries = 2
end
