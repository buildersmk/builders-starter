# builders-starter — agent context

A lean, production-shaped Rails 8 starter: passwordless auth, multi-tenant-ready accounts, billing,
email, and a marketing funnel — each integration wired but **idle until you add its key**. Clone it,
add your product, ship. Read this first; read [STYLE.md](STYLE.md) before writing Ruby.

## 1. Stack

- **Rails 8.1** on **Ruby 3.4** · **Hotwire** (Turbo + Stimulus) · **importmap + Propshaft** (no node build)
- **Tailwind v4** via `tailwindcss-rails` (design tokens in `app/assets/tailwind/application.css`)
- **SQLite** in development & test (a file on disk — nothing to install), **PostgreSQL** in production
- **Solid Queue / Cache / Cable** — all in the one primary database (nothing extra to provision)
- **Kamal** → any Docker host · **Minitest** + fixtures + Capybara system tests
- Prod DB target: **Supabase** (the production `database.yml` is pooler-ready); `pg` is a `:production`-group gem

## 2. Core model — Account / Identity / User / Session

- **Identity** — a person's global, passwordless login (one email). Holds the 6-digit login-code state
  and the sessions. `app/models/identity.rb` (+ `identity/login_code.rb`).
- **Account** — the tenant. Owns data and the subscription. `app/models/account.rb`
  (+ `account/multi_tenantable.rb`, `account/billable.rb`).
- **User** — the membership of an Identity in one Account (per-account `name` + `role`). `app/models/user.rb`.
- **Session** — a signed-in browser, tied to the Identity. `app/models/session.rb`.
- **Current** (`app/models/current.rb`) — resolves per request: `account` → `session` → `identity` → `user`.

**Tenancy.** Single-tenant by default (`Current.account` = the one account, clean URLs). Set
`MULTI_TENANT=true` to run one account per customer, resolved by **subdomain** (`SetCurrentAccount`).
`Account.accepting_signups?` = `multi_tenant || Account.none?`, so a single-tenant app lets the first
visitor become the owner, then closes signups (others join by invite — build that when you need it).

**Auth.** Passwordless 6-digit codes (no passwords, no OAuth). `app/controllers/concerns/authentication.rb`
+ `session_codes` (email → code), `sessions` (verify → session), `registrations` (sign up). Codes are
bcrypt-hashed, expire in 15 min, throttle resends, and lock after 5 tries. In development the code is
**shown right on the sign-in page** (and logged, and emails open via letter_opener), so there's nothing
to hunt for. The first visitor to sign up becomes the owner.

## 3. Integrations — idle until keyed

Each no-ops (or self-serves, in dev) until its ENV key is set. See `.env.example` for every key +
where to get it. `bin/setup` leads with a local `.env` (default); Doppler is an explicit opt-in
(`doppler run -- bin/dev`). The catalog of integrations + where-to-get-each-key is also in
`app/models/starter_guide.rb`, surfaced to the founder on the dev-only Starter Guide (see §7).

| What | Where | Key |
|---|---|---|
| **Stripe** — subscription (checkout + portal + webhook) | `app/services/billing.rb`, `*_controller.rb`, `lib/tasks/stripe.rake` | `STRIPE_SECRET_KEY` |
| **Resend** — transactional email (SMTP) | `config/environments/production.rb`, `app/mailers/` | `RESEND_API_KEY` |
| **Kit** — lead capture → subscribe + tag | `app/services/kit_tagger.rb`, `leads_controller.rb` | `KIT_API_KEY` |
| **OpenRouter** — one client for any LLM | `app/services/open_router_client.rb` | `OPENROUTER_API_KEY` |
| **Apify** — scraping actors (sync/async) | `app/services/apify_client.rb` | `APIFY_API_TOKEN` |

Billing is **account-level** (the tenant subscribes). With no Stripe key, checkout "self-serves" the
account to Pro so the flow is walkable in dev. One subscription product, resolved by a stable price
`lookup_key` — run `bin/rails stripe:setup` to create it.

## 4. Surfaces

- **Marketing** (`layout "marketing"`, public): `home#show` (hero + funnel + lead capture), `pricing#show`.
- **App** (`layout "application"`, authenticated): `dashboard#show`.
- **Auth** (`layout "auth"`): `sessions#new`, `registrations#new`.

## 5. Running it

```bash
bin/setup          # deps, set up .env (or Doppler), prepare the SQLite dev database
bin/dev            # Puma + Tailwind watcher on http://localhost:3100
bin/rails test     # Minitest (SQLite; add PARALLEL_WORKERS=1 if pg/sqlite forking misbehaves)
bin/rubocop        # omakase style
```

Development needs **no database to install** — SQLite lives under `storage/`. The `DATABASE_*` env
vars are production-only (Postgres/Supabase). Prefer Doppler? Run through it explicitly:
`doppler run -- bin/dev` and `doppler run -- claude` (so the app *and* your AI agent get the keys).

## 6. House rules (and see STYLE.md)

- **Vanilla Rails**: thin controllers calling rich models; behavior lives on models, composed of small
  concerns namespaced under them (`app/models/account/billable.rb`). Services are for genuine boundaries
  (Stripe, Kit, LLM, scraping) — not a default home for logic.
- **CRUD-only controllers**: a non-CRUD verb becomes a nested resource, not a custom action.
- **`_later`/`_now` jobs**: shallow jobs delegate to a model method.
- Omakase style (`rubocop-rails-omakase`): double quotes, indented `private`, expanded conditionals.
- Don't ship behavior without a covering test. Update `.env.example` when you add a key.
- Keep integrations idle-until-keyed: read the key, no-op (or log a warning) when it's absent.

## 7. Starter Guide (development only)

Onboarding for the (often non-technical) founder who cloned this kit — it never ships to production.

- **Welcome + checklist** — in development, `home#show` renders `home/welcome.html.erb` (a setup
  checklist with live integration status) instead of the marketing page. The marketing page they'll
  customize is at `/preview` (`home#marketing`) and is the production home.
- **The guide** — `/guide` (`GuideController`, dev-only route + guard) renders a plain-language,
  outcome-first how-to: what's inside, turning on each tool, "make it yours with Claude", going live.
- **Single source of truth** — the integration catalog is `app/models/starter_guide.rb`; the agent-
  readable mirror is **[GUIDE.md](GUIDE.md)** (exact env vars, commands, verify steps) and
  **[PROMPTS.md](PROMPTS.md)** (the founder's copy-ready asks). Change them together when you add a tool.
- Motion is CSS-first (`application.css`) with one small inline script (`guide/_behaviors.html.erb`);
  everything degrades gracefully with no JS. Dev-only pages are gated on `Rails.env.development?`.
