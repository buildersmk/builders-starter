Rails.application.routes.draw do
  # --- Auth (passwordless, 6-digit code) ---
  resource :session, only: %i[ new create destroy ]  # new = email/code step, create = verify, destroy = sign out
  resource :session_code, only: :create              # POST an email → we send a 6-digit code
  get  "signup", to: "registrations#new",    as: :new_registration
  post "signup", to: "registrations#create", as: :registration

  # --- Billing (Stripe — idle until keyed) ---
  get "pricing", to: "pricing#show", as: :pricing
  resource :subscription, only: :create
  get "subscription/success", to: "subscriptions#success", as: :subscription_success
  get "billing/portal", to: "subscriptions#portal", as: :billing_portal
  post "stripe/webhooks", to: "stripe_webhooks#create", as: :stripe_webhooks

  # --- Marketing lead capture (Kit — idle until keyed) ---
  resource :lead, only: :create

  # --- App (authenticated) ---
  get "dashboard", to: "dashboard#show", as: :dashboard

  # Health check (load balancers / uptime monitors).
  get "up" => "rails/health#show", as: :rails_health_check

  # --- Marketing home (public) ---
  root "home#show"
end
