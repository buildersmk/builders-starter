# The catalog behind the dev-only Starter Guide and the first-run welcome checklist — a single
# source of truth so the two never drift. Each integration knows its key, where to get it, and
# whether it's live right now (its ENV var is set). Development-facing only.
module StarterGuide
  Integration = Data.define(:key, :name, :logo, :tagline, :env_var, :extra_env, :where_url, :where_label, :optional) do
    def configured? = ENV[env_var].present?
    def optional? = optional
  end

  INTEGRATIONS = [
    Integration.new(
      key: "stripe", name: "Stripe", logo: "logos/stripe.svg",
      tagline: "Take payments — subscriptions, checkout, and a self-serve customer portal.",
      env_var: "STRIPE_SECRET_KEY", extra_env: %w[ STRIPE_WEBHOOK_SECRET ],
      where_url: "https://dashboard.stripe.com/apikeys",
      where_label: "Stripe dashboard → Developers → API keys (use test keys while you build)",
      optional: false
    ),
    Integration.new(
      key: "resend", name: "Resend", logo: "logos/resend.svg",
      tagline: "Send email people actually receive — welcomes, receipts, and login codes.",
      env_var: "RESEND_API_KEY", extra_env: [],
      where_url: "https://resend.com/api-keys",
      where_label: "Resend → API Keys (verify your sending domain first)",
      optional: false
    ),
    Integration.new(
      key: "kit", name: "Kit", logo: "logos/kit.svg",
      tagline: "Grow your email list — new signups flow straight into your newsletter.",
      env_var: "KIT_API_KEY", extra_env: %w[ KIT_TAG_ID ],
      where_url: "https://app.kit.com/account_settings/developer_settings",
      where_label: "Kit → Settings → Developer → API Key",
      optional: true
    ),
    Integration.new(
      key: "openrouter", name: "OpenRouter", logo: "logos/openrouter.svg",
      tagline: "Add AI features — one key reaches every major model (Claude, GPT, Gemini…).",
      env_var: "OPENROUTER_API_KEY", extra_env: [],
      where_url: "https://openrouter.ai/keys",
      where_label: "OpenRouter → Keys",
      optional: true
    ),
    Integration.new(
      key: "apify", name: "Apify", logo: "logos/apify.svg",
      tagline: "Pull data from the web — scraping and enrichment, only if your product needs it.",
      env_var: "APIFY_API_TOKEN", extra_env: [],
      where_url: "https://console.apify.com/account/integrations",
      where_label: "Apify → Settings → Integrations",
      optional: true
    )
  ].freeze

  def self.integrations = INTEGRATIONS
  def self.essential = INTEGRATIONS.reject(&:optional?)
  def self.optional = INTEGRATIONS.select(&:optional?)
  def self.configured_count = INTEGRATIONS.count(&:configured?)
end
