# Setup guide (canonical)

The same steps as the in-app Starter Guide (`/guide`, development only), written as exact,
unambiguous instructions — for an AI agent, or a founder who prefers plain text. Humans get the
friendly version in the app; this is the source of truth for names, commands and "done when" checks.

> The in-app guide at `/guide` and the welcome checklist at `/` (both development only) are built
> from `app/models/starter_guide.rb`. Keep this file and that catalog in sync when you add a tool.

## Run it locally

```bash
bin/setup     # installs gems, prepares the SQLite dev database
bin/dev       # http://localhost:3100
```

- **Done when:** the home page loads at `localhost:3100` and shows the welcome checklist.
- **Database:** development & test use SQLite (a file under `storage/`). Nothing to install.
- **Sign in:** `/session/new` → enter an email → the 6-digit code is shown on the page in
  development (and logged, and emailed via letter_opener). The first sign-up becomes the owner.

## Integrations

Each is wired but idle until its env var is set (put it in `.env`, or Doppler). Restart to pick up
a new key. Status is live on `/guide` and `/` (green = the env var is present).

### Stripe — payments (essential)
- **Env:** `STRIPE_SECRET_KEY` (required), `STRIPE_WEBHOOK_SECRET` (for live webhook events).
- **Get it:** https://dashboard.stripe.com/apikeys (use test keys while building).
- **Steps:** set `STRIPE_SECRET_KEY` → `bin/rails stripe:setup` (creates the Pro product + price) →
  `bin/rails "stripe:webhook[https://yourdomain.com]"` (prints the signing secret → set `STRIPE_WEBHOOK_SECRET`).
- **Verify:** `/pricing` → subscribe with test card `4242 4242 4242 4242` → account becomes Pro.
- **Common failures:** no key → checkout self-serves the account to Pro in dev (expected). Webhook
  secret missing → live events rejected; fine for local testing.

### Resend — transactional email (essential)
- **Env:** `RESEND_API_KEY`.
- **Get it:** https://resend.com/api-keys (verify your sending domain first).
- **Steps:** set `RESEND_API_KEY`. Production sends over SMTP (`smtp.resend.com`, see
  `config/environments/production.rb`). Development opens mail in the browser (letter_opener) and
  prints login codes on-screen — no key needed to develop.
- **Verify:** trigger a login code in production and confirm delivery to a real inbox.

### Kit (ConvertKit) — email list (optional)
- **Env:** `KIT_API_KEY`, `KIT_TAG_ID` (optional tag applied to new leads).
- **Get it:** https://app.kit.com → Settings → Developer → API Key.
- **Steps:** set `KIT_API_KEY`. The marketing lead form (`leads#create` → `KitTagger`) subscribes +
  tags. No key → the form accepts the email and no-ops.
- **Verify:** submit the home-page email form → subscriber appears in Kit.

### OpenRouter — AI models (optional)
- **Env:** `OPENROUTER_API_KEY`.
- **Get it:** https://openrouter.ai/keys.
- **Steps:** set the key; call `OpenRouterClient.new.chat(...)` (`app/services/open_router_client.rb`).
- **Verify:** a chat call returns text. No key → raises a clear "not configured" error.

### Apify — web scraping (optional)
- **Env:** `APIFY_API_TOKEN`.
- **Get it:** https://console.apify.com/account/integrations.
- **Steps:** set the token; use `ApifyClient` (`run` / `run_async`, `app/services/apify_client.rb`).
- **Verify:** an actor run returns a dataset. No token → raises a clear "not configured" error.

## Make it yours

Change the product by editing code — but a non-technical owner does it by asking you. The founder's
copy-ready requests live in [PROMPTS.md](PROMPTS.md). Typical edits: marketing copy
(`app/views/home/_marketing.html.erb`), brand colour/tokens (`app/assets/tailwind/application.css`
`@theme`), new pages (add a CRUD-only controller + route + view), renames (grep the term).

## Go live

1. Replace every test key with its live equivalent (same env var names).
2. Set the production host/domain and `DATABASE_*` (Postgres/Supabase) — see `config/deploy.yml`,
   `config/database.yml`, `.kamal/secrets`.
3. Deploy: `kamal setup` (first time) then push to `main` (CI deploys), or `kamal deploy`.
- **Done when:** the domain serves the app over HTTPS, a live test payment succeeds, and a real
  welcome email arrives.
