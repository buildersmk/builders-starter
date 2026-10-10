# The subscription plans. Two is plenty for a starter: free and pro. `LOOKUP_KEY` is the stable
# Stripe price lookup_key (see lib/tasks/stripe.rake) — repoint the price in Stripe without a code
# change. PRICE/INTERVAL are display-only; the real charge is whatever the Stripe price says.
module Plan
  FREE = "free"
  PRO  = "pro"
  ALL  = [ FREE, PRO ].freeze

  LOOKUP_KEY = "pro_monthly"
  PRICE      = 20      # $ / month — display only
  INTERVAL   = "month" # display only
end
